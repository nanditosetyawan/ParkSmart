// PS-05 Slot Selection — Reconstructed from actual Stitch HTML
// Colors from Stitch config: secondary=#9a442d, surface-container-lowest=#fff
// primary-container=#1c1d1f, secondary-container=#fc9174, tertiary-fixed=#bbeed4
// Slot grid: 4 cols, aspect-[3/4], rounded-lg (2rem in Stitch = 16px in Flutter)
// Floor tabs: rounded-full pills
// CTA: rounded-full bg-primary-container text-surface-bright (= charcoal bg)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../checkout/checkout_screen.dart';

// Stitch Material3 slot colors — verified from HTML source
const _kSecondary = Color(0xFF9A442D);
const _kSecondaryFixed = Color(0xFFFFDBD2);      // pale orange bg for selected badge
const _kPrimaryContainer = Color(0xFF1C1D1F);    // charcoal — active slot & CTA
const _kTertiaryFixed = Color(0xFFBBEED4);       // pale green — EV icon circle
const _kSurfaceContainerLow = Color(0xFFF6F3EC); // warm cream — bg
const _kSurfaceContainerHigh = Color(0xFFEBE8E1); // dull — occupied bg
const _kSurfaceContainerLowest = Color(0xFFFFFFFF); // white — available slot

class SlotSelectionScreen extends StatefulWidget {
  const SlotSelectionScreen({super.key});
  @override
  State<SlotSelectionScreen> createState() => _SlotSelectionScreenState();
}

class _SlotSelectionScreenState extends State<SlotSelectionScreen> {
  String? _selectedSlot;
  int _selectedFloor = 1; // B2 is index 1

  final _floors = ['Lantai B1', 'Lantai B2', 'Lantai B3', 'Lantai B4 (Khusus Valet)'];

  // Mock data — slot id to availability
  final _slotsA = {
    'A-03': true,  'A-04': false,
    'A-05': true,  'A-06': false,
  };
  final _slotsB = {
    'B-01': false, 'B-02': true,
    'B-03': false, 'B-04': true, // B-04 is EV
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2), // surface from Stitch
      body: Stack(
        children: [
          // ─── Scrollable content ──────────────────────────────
          ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 72), // header spacer

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 6),

                  // ─── Summary card ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _kSurfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF1C1D1F).withOpacity(0.06), offset: const Offset(0, 12), blurRadius: 32, spreadRadius: -8),
                        BoxShadow(color: const Color(0xFF1C1D1F).withOpacity(0.03), offset: const Offset(0, 4), blurRadius: 12, spreadRadius: -2),
                      ],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // location + ANPR badge
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Row(children: [
                          const Icon(Icons.location_on, size: 18, color: _kSecondary),
                          const SizedBox(width: 6),
                          Text('Central Park Mall • 350m',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5,
                              color: const Color(0xFF45474A), decoration: null),
                          ),
                        ]),
                        const SizedBox(),
                      ]),
                      const SizedBox(height: 8),
                      // slot count
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('28 Slot',
                            style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                          ),
                          Text('Siap pakai di Basement B2', style: AppTypography.bodySm(color: const Color(0xFF45474A))),
                        ]),
                        Row(children: [
                          Align(widthFactor: 0.75, child: _AmenityBadge(color: _kTertiaryFixed, icon: Icons.ev_station)),
                          Align(widthFactor: 0.75, child: _AmenityBadge(color: const Color(0xFFEBE8E1), icon: Icons.accessible)),
                          _CountBadge(count: '+4'),
                        ]),
                      ]),
                      const SizedBox(height: 12),
                      // tip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E2DB))),
                        child: Row(children: [
                          const Icon(Icons.tips_and_updates_outlined, size: 18, color: AppColors.accentTeal),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Zona A lebih dekat ke Lobby Tribeca & Central Park Lift.',
                            style: AppTypography.bodySm(color: const Color(0xFF45474A)))),
                        ]),
                      ),
                    ]),
                  ),

                  // ─── Floor selector tabs ──────────────────────
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _floors.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final active = i == _selectedFloor;
                        return GestureDetector(
                          onTap: () => setState(() { _selectedFloor = i; _selectedSlot = null; }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: active ? _kPrimaryContainer : _kSurfaceContainerLowest,
                              borderRadius: AppRadii.pillRadius,
                              boxShadow: const [AppShadows.soft],
                            ),
                            child: Row(children: [
                              Text(_floors[i], style: GoogleFonts.plusJakartaSans(
                                fontSize: 14, fontWeight: FontWeight.w600,
                                color: active ? const Color(0xFFFCF9F2) : const Color(0xFF45474A),
                              )),
                              if (active) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 6, height: 6,
                                  decoration: BoxDecoration(color: const Color(0xFFFC9174), shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 4),
                                Text('Terpilih', style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFFCF9F2).withOpacity(0.8),
                                )),
                              ],
                            ]),
                          ),
                        );
                      },
                    ),
                  ),

                  // ─── Parking map canvas ───────────────────────
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _kSurfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFF1C1D1F).withOpacity(0.04), offset: const Offset(0, 2), blurRadius: 8)],
                    ),
                    child: Column(children: [
                      

                      // Zone A
                      _ZoneLabel(label: 'Zona A', count: '3 Tersedia'),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10,
                        childAspectRatio: 3 / 4,
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildSlot('A-03', true),
                          _buildSlot('A-04', false),
                          _buildSlot('A-05', true, isSelected: _selectedSlot == 'A-05'),
                          _buildSlot('A-06', false),
                        ],
                      ),

                      // Circulation aisle
                      const SizedBox(height: 12),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: _kSurfaceContainerHigh.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.east, size: 14, color: Color(0xFF45474A)),
                          const SizedBox(width: 6),
                          Text('Jalur Sirkulasi B2', style: AppTypography.caption(color: const Color(0xFF45474A))),
                          const SizedBox(width: 6),
                          const Icon(Icons.navigation_outlined, size: 14, color: Color(0xFF45474A)),
                          const SizedBox(width: 4),
                          Text('Satu Arah', style: AppTypography.caption(color: const Color(0xFF45474A))),
                        ]),
                      ),
                      const SizedBox(height: 12),

                      // Zone B
                      _ZoneLabel(label: 'Zona B', count: '2 Tersedia'),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10,
                        childAspectRatio: 3 / 4,
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildSlot('B-01', false),
                          _buildSlot('B-02', true, isSelected: _selectedSlot == 'B-02'),
                          _buildSlot('B-03', false, isEV: true),
                          _buildSlot('B-04', true, isEV: true, isSelected: _selectedSlot == 'B-04'),
                        ],
                      ),

                      // Legend
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        _LegendItem(color: _kSurfaceContainerLowest, label: 'Tersedia', border: const Color(0xFFC6C6CA)),
                        _LegendItem(color: _kSurfaceContainerHigh.withOpacity(0.6), label: 'Terisi Mobil'),
                        _LegendItem(color: _kPrimaryContainer, label: 'Pilihan Anda'),
                      ]),
                    ]),
                  ),

                  const SizedBox(height: 120),
                ]),
              ),
            ],
          ),

          // ─── Fixed header ─────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 64,
                color: const Color(0xFFFCF9F2).withOpacity(0.9),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: _kSurfaceContainerHigh.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Slot Selection', style: GoogleFonts.plusJakartaSans(
                        fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3,
                      )),
                    ]),
                    ClipOval(
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida/AEtjO1X6p5Mv8Oi1XLvN093rFeTJnMCOZmqDO2uSQZYGuB-RB6f83CsECwm8-1NdXIz_6VM9C78Bm8crVKK5iRJzBdezhrEKwLMqK3SR6KEjS1zKGR56CnDbuOvOutLyydoSwylEK_bwBZ8X9UCr5IMUydYrY5_7XLRKPSGb0xkkUzMYxEtinxlVuZkHQBbkIvqobf82hAucjcAgO17syoVGIKw-4aXA7298-QPj0g1UsnGqNRW9hU6CaLLbwLA',
                        width: 32, height: 32, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 32, height: 32, color: const Color(0xFFEBE8E1)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Bottom floating summary / CTA ────────────────────
          if (_selectedSlot != null)
            Positioned(
              bottom: 16, left: AppSpacing.pageH, right: AppSpacing.pageH,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kSurfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF1C1D1F).withOpacity(0.20), offset: const Offset(0, 16), blurRadius: 40, spreadRadius: -10),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('TOTAL PEMBAYARAN AWAL', style: AppTypography.overline(color: const Color(0xFF45474A)), overflow: TextOverflow.ellipsis, maxLines: 1),
                          const SizedBox(height: 2),
                          Text('Rp 5.000', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                          Text('(1 Jam Pertama)', style: AppTypography.caption(color: const Color(0xFF45474A)), overflow: TextOverflow.ellipsis, maxLines: 1),
                        ]),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: _kPrimaryContainer, borderRadius: AppRadii.pillRadius,
                          boxShadow: const [AppShadows.float]),
                        child: Row(children: [
                          Text('Lanjut Bayar', style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFFCF9F2),
                          )),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFFCF9F2)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlot(String id, bool isAvailable, {bool isSelected = false, bool isEV = false}) {
    final selected = isSelected;
    Color bg;
    Color? border;
    Widget icon;
    Widget label;

    if (selected) {
      bg = _kPrimaryContainer;
      border = null;
      icon = const Icon(Icons.check_circle, size: 18, color: Color(0xFFFCF9F2));
      label = Text('Pilihan', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFFFCF9F2)));
    } else if (!isAvailable) {
      bg = _kSurfaceContainerHigh.withOpacity(0.6);
      border = null;
      icon = const Icon(Icons.directions_car, size: 18, color: Color(0xFF45474A));
      label = Text('Terisi', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w500, color: const Color(0xFF45474A)));
    } else {
      bg = _kSurfaceContainerLowest;
      border = const Color(0xFFC6C6CA);
      icon = isEV
          ? Container(width: 24, height: 24,
              decoration: const BoxDecoration(color: _kTertiaryFixed, shape: BoxShape.circle),
              child: const Icon(Icons.bolt, size: 14, color: Color(0xFF002115)))
          : const SizedBox();
      label = Text('Siap', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w500, color: const Color(0xFF45474A)));
    }

    return GestureDetector(
      onTap: isAvailable ? () => setState(() => _selectedSlot = selected ? null : id) : null,
      child: AnimatedScale(
        scale: selected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: border != null ? Border.all(color: border) : null,
                boxShadow: selected
                    ? [BoxShadow(color: _kPrimaryContainer.withOpacity(0.2), offset: const Offset(0, 4), blurRadius: 12)]
                    : const [AppShadows.soft],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Text(id, style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: selected ? const Color(0xFFFCF9F2) : const Color(0xFF1C1C18),
                  )),
                  icon,
                  Padding(padding: const EdgeInsets.only(bottom: 6), child: label),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: -10, left: 0, right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: _kSecondary, borderRadius: AppRadii.pillRadius),
                    child: Text('Dipilih', style: GoogleFonts.plusJakartaSans(
                      fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5,
                    )),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ZoneLabel extends StatelessWidget {
  final String label;
  final String count;
  const _ZoneLabel({required this.label, required this.count});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label.toUpperCase(), style: GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: const Color(0xFF45474A),
      )),
      Text(count, style: GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w600, color: _kSecondary,
      )),
    ],
  );
}

class _AmenityBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _AmenityBadge({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    width: 32, height: 32,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: const [AppShadows.soft]),
    child: Icon(icon, size: 16, color: const Color(0xFF002115)),
  );
}

class _CountBadge extends StatelessWidget {
  final String count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) => Container(
    width: 32, height: 32,
    decoration: BoxDecoration(color: const Color(0xFFFC9174), shape: BoxShape.circle),
    child: Center(child: Text(count, style: GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF742814),
    ))),
  );
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final Color? border;
  const _LegendItem({required this.color, required this.label, this.border});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 12, height: 12,
      decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(3),
        border: border != null ? Border.all(color: border!) : null,
      )),
    const SizedBox(width: 6),
    Text(label, style: GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF45474A),
    )),
  ]);
}
