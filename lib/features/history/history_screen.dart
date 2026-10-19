import 'package:flutter/material.dart';
import '../../widgets/bottom_dock_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import 'history_detail_screen.dart' as history_detail;
import 'backend/history_backend.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    HistoryBackend.instance.fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, HistoryBackend.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;
        final backend = HistoryBackend.instance;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : const Color(0xFFFAF7F2),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      decoration: BoxDecoration(
                        color: (isDark ? theme.bg : const Color(0xFFFAF7F2)).withValues(alpha: 0.85),
                        border: Border(
                          bottom: BorderSide(
                            color: (isDark ? theme.border : const Color(0xFFE5E2DB)).withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'PARKSMART PORTAL',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFFE07A5F) : const Color(0xFF9A442D),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF059669),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Riwayat Parkir',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Riwayat Transaksi Parkir',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? theme.textMuted : const Color(0xFF76777B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
                        children: [
                          // Filter Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _FilterChip(
                                  label: 'Semua',
                                  count: '${backend.items.length}',
                                  isSelected: backend.selectedFilter == 'all',
                                  isDark: isDark,
                                  onTap: () => backend.setFilter('all'),
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: 'Selesai',
                                  isSelected: backend.selectedFilter == 'completed',
                                  isDark: isDark,
                                  onTap: () => backend.setFilter('completed'),
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: 'Aktif',
                                  isSelected: backend.selectedFilter == 'active',
                                  isDark: isDark,
                                  onTap: () => backend.setFilter('active'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Loading state
                          if (backend.isLoading)
                            const Center(child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ))
                          else if (backend.items.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  'Belum ada riwayat parkir.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B),
                                  ),
                                ),
                              ),
                            )
                          else
                            ...backend.items.asMap().entries.map((e) {
                              final item = e.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _HistoryCard(
                                  id: item.id,
                                  mallName: item.mallName,
                                  date: item.date,
                                  status: item.status,
                                  statusColor: item.statusColor,
                                  duration: item.duration,
                                  slot: item.slot,
                                  price: item.price,
                                  icon: item.icon,
                                  isEv: item.isEv,
                                  isDark: isDark,
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Center(
                  child: BottomDockNavigation(activeTab: DockTab.history),
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
  final String? count;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  
  const _FilterChip({
    required this.label,
    this.count,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    
    if (isSelected) {
      bgColor = isDark ? Colors.white : const Color(0xFF1C1D1F);
      textColor = isDark ? const Color(0xFF111418) : Colors.white;
    } else {
      bgColor = isDark ? const Color(0xFF1E232B) : const Color(0xFFF1EEE7);
      textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: isDark && !isSelected ? Border.all(color: const Color(0xFF2D3542)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: textColor,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF111418).withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.2))
                      : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFF1C1D1F).withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String id;
  final String mallName;
  final String date;
  final String status;
  final Color statusColor;
  final String duration;
  final String slot;
  final String price;
  final IconData icon;
  final bool isEv;
  final bool isDark;

  const _HistoryCard({
    required this.id,
    required this.mallName,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.duration,
    required this.slot,
    required this.price,
    required this.icon,
    this.isEv = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E232B) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF2D3542) : const Color(0xFFEBE8E1);
    final textMain = isDark ? Colors.white : const Color(0xFF1C1C18);
    final textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B);
    final innerBoxBg = isDark ? const Color(0xFF14181E) : Colors.white;
    final iconBoxBg = isDark ? Colors.white : const Color(0xFF1C1D1F);
    final iconColor = isDark ? const Color(0xFF111418) : Colors.white;
    final dividerColor = isDark ? const Color(0xFF2D3542) : const Color(0xFFF1EEE7);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => history_detail.HistoryDetailScreen(id: id)));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF1C1D1F).withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconBoxBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.transparent : const Color(0xFFEBE8E1)),
                      ),
                      child: Icon(icon, size: 24, color: iconColor),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mallName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.calendar_month, size: 14, color: textSub),
                            const SizedBox(width: 4),
                            Text(
                              date,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textSub,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF059669).withValues(alpha: 0.5)
                          : const Color(0xFFA7F3D0).withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: innerBoxBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder.withValues(alpha: 0.8)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Durasi',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: textSub),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.timer, size: 16, color: textSub),
                            const SizedBox(width: 4),
                            Text(
                              duration,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textMain,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Slot & Area',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: textSub),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              isEv ? Icons.bolt : Icons.pin_drop,
                              size: 16,
                              color: isEv ? const Color(0xFF059669) : (isDark ? const Color(0xFFE07A5F) : const Color(0xFF9A442D)),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              slot,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textMain,
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
            const SizedBox(height: 12),
            Divider(color: dividerColor, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: textSub),
                    ),
                    Text(
                      price,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textMain,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.transparent : const Color(0xFFE5E2DB)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified, size: 15, color: isDark ? const Color(0xFF059669) : const Color(0xFF047857)),
                      const SizedBox(width: 6),
                      Text(
                        'Verified by Blockchain',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF111418) : Colors.white,
                        ),
                      ),
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
