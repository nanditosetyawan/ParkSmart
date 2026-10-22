import 'package:flutter/material.dart';
import 'history_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import '../profile/backend/vehicle_backend.dart';
import 'backend/verified_parking_sessions_backend.dart';

class VerifiedParkingSessionsScreen extends StatefulWidget {
  final String? vehicleId;
  final VehicleItem? vehicleItem;

  const VerifiedParkingSessionsScreen({
    super.key,
    this.vehicleId,
    this.vehicleItem,
  });

  @override
  State<VerifiedParkingSessionsScreen> createState() => _VerifiedParkingSessionsScreenState();
}

class _VerifiedParkingSessionsScreenState extends State<VerifiedParkingSessionsScreen> {
  String _selectedFilter = 'Semua Bulan';

  @override
  void initState() {
    super.initState();
    VerifiedParkingSessionsBackend.instance.fetchSessions(
      vehicleId: widget.vehicleId,
      vehicleItem: widget.vehicleItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, VerifiedParkingSessionsBackend.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;
        final backend = VerifiedParkingSessionsBackend.instance;

        final bg = isDark ? theme.bg : const Color(0xFFFCF9F2);
        final cardBg = isDark ? theme.card : Colors.white;
        final cardBorder = isDark ? theme.border : const Color(0xFFE5E2DB).withValues(alpha: 0.7);
        final textMain = isDark ? Colors.white : const Color(0xFF1C1C18);
        final textSub = isDark ? theme.textMuted : const Color(0xFF45474A);
        final surface = isDark ? theme.surfaceField : Colors.white;

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg.withValues(alpha: 0.8),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textMain),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Riwayat Parkir Kendaraan',
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: textMain),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(icon: Icon(Icons.share, color: textSub), onPressed: () {}),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 1. Vehicle Context Hero
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: backend.isDefault
                                ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFFBBEED4))
                                : (isDark ? const Color(0xFF78350F).withValues(alpha: 0.5) : const Color(0xFFFEF3C7)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                backend.isDefault ? Icons.stars : Icons.shield_outlined,
                                size: 15,
                                color: backend.isDefault
                                    ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF002115))
                                    : (isDark ? const Color(0xFFFCD34D) : const Color(0xFF92400E)),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                backend.isDefault ? 'Kendaraan Utama' : 'Kendaraan Cadangan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: backend.isDefault
                                      ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF002115))
                                      : (isDark ? const Color(0xFFFCD34D) : const Color(0xFF92400E)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 96,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isDark ? theme.surfaceField : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(16),
                            image: (backend.photoUrl != null && backend.photoUrl!.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(backend.photoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (backend.photoUrl == null || backend.photoUrl!.isEmpty)
                              ? Icon(
                                  Icons.directions_car,
                                  size: 40,
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(backend.vehiclePlate, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: textMain)),
                              Text(backend.vehicleInfo, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: textSub)),
                              const SizedBox(height: 8),
                              const SizedBox(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text('Total Sesi', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textSub)),
                              Text('${backend.totalSessions} Kali', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: textMain)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Total Durasi', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textSub)),
                              Text('${backend.totalDurationHours} Jam', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: textMain)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Bulan Ini', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textSub)),
                              Text(
                                backend.thisMonthSpending,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFE07A5F) : const Color(0xFF9A442D),
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

              const SizedBox(height: 24),

              // 2. Filter Chips
           

              const SizedBox(height: 24),

              // 3. Header List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('Sesi Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: textMain)),
                      const SizedBox(width: 8),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Urutkan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFE07A5F) : const Color(0xFF9A442D),
                        ),
                      ),
                      Icon(Icons.swap_vert, size: 16, color: isDark ? const Color(0xFFE07A5F) : const Color(0xFF9A442D)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 4. History Items
              if (backend.sessions.isEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E232B) : const Color(0xFFF1EEE7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_user_outlined,
                          size: 40,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum Ada Sesi Terverifikasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textMain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Riwayat transaksi parkir yang telah divalidasi ke blockchain akan tampil di sini.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: textSub,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...backend.sessions.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HistoryItem(
                      id: item.id,
                      mallName: item.locationName,
                      slot: item.slot,
                      price: item.amount,
                      paymentMethod: 'Auto-Debit',
                      date: item.date,
                      duration: item.duration,
                      timeIn: item.timeIn,
                      timeOut: item.timeOut,
                      status: item.status,
                      icon: Icons.local_parking,
                      isDark: isDark,
                    ),
                  )),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : const Color(0xFF020304), // reversed!
                  foregroundColor: isDark ? const Color(0xFF111418) : Colors.white, // reversed!
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download, size: 20),
                    const SizedBox(width: 8),
                    Text('Unduh Rekap Parkir (PDF)', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? (isDark ? Colors.white : const Color(0xFF020304))
        : (isDark ? const Color(0xFF1E232B) : Colors.white);
    final textColor = isSelected
        ? (isDark ? const Color(0xFF111418) : Colors.white)
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: isDark && !isSelected ? Border.all(color: const Color(0xFF2D3542)) : null,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: isDark ? Colors.black45 : Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 6),
            ],
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String id;
  final String mallName;
  final String slot;
  final String price;
  final String paymentMethod;
  final String date;
  final String duration;
  final String timeIn;
  final String timeOut;
  final String status;
  final IconData icon;
  final bool isDark;

  const _HistoryItem({
    required this.id,
    required this.mallName,
    required this.slot,
    required this.price,
    required this.paymentMethod,
    required this.date,
    required this.duration,
    required this.timeIn,
    required this.timeOut,
    required this.status,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E232B) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB).withValues(alpha: 0.7);
    final textMain = isDark ? Colors.white : const Color(0xFF1C1C18);
    final textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A);
    final surface = isDark ? const Color(0xFF14181E) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF14181E) : const Color(0xFFF1EEE7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: isDark ? Colors.white : const Color(0xFF020304)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mallName, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: textMain)),
                    Row(
                      children: [
                        Icon(Icons.pin_drop, size: 14, color: textSub),
                        const SizedBox(width: 4),
                        Text(slot, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textSub)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: textMain)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: textMain),
                        const SizedBox(width: 6),
                        Text(date, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: textMain)),
                      ],
                    ),
                    Text(duration, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: textSub)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(timeIn, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textSub)),
                    const Icon(Icons.arrow_forward, size: 14, color: Color(0xFFC6C6CA)),
                    Text(timeOut, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textSub)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFFBBEED4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 13, color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF002115)),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF002115),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryDetailScreen(id: id)));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : const Color(0xFF1C1D1F), // reversed!
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, size: 15, color: isDark ? const Color(0xFF111418) : Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        'E-Receipt',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF111418) : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
