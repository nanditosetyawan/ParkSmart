import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'backend/all_locations_revenue_backend.dart';

class AllLocationsRevenueScreen extends StatefulWidget {
  const AllLocationsRevenueScreen({super.key});

  @override
  State<AllLocationsRevenueScreen> createState() => _AllLocationsRevenueScreenState();
}

class _AllLocationsRevenueScreenState extends State<AllLocationsRevenueScreen> {
  bool get _isLoading => AllLocationsRevenueBackend.instance.isLoading;

  List<Map<String, dynamic>> get _locations =>
      AllLocationsRevenueBackend.instance.locations;

  @override
  void initState() {
    super.initState();
    // Memanggil database hanya sekali saat halaman dibuka
    _fetchFromDatabase(isInitial: true);
  }

  Future<void> _fetchFromDatabase({bool isInitial = false}) async {
    final sm = ScaffoldMessenger.of(context);
    await AllLocationsRevenueBackend.instance.fetchLocationsRevenue();

    if (!mounted) return;

    if (!isInitial) {
      sm.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Data omzet seluruh lokasi berhasil diperbarui',
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF17A18A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AllLocationsRevenueBackend.instance,
      builder: (context, _) {
        return Theme(
          data: AppTheme.light,
          child: Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18)),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kontribusi Omzet per Lokasi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                  ),
                  Text(
                    'Daftar lengkap kontribusi pendapatan seluruh gedung',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                  ),
                ],
              ),
              actions: [
                // Tombol Reload untuk memanggil ulang data dari database
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF114177)),
                        )
                      : const Icon(Icons.refresh_rounded, color: Color(0xFF114177), size: 22),
                  tooltip: 'Muat Ulang Database',
                  onPressed: _isLoading ? null : () => _fetchFromDatabase(isInitial: false),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () => _fetchFromDatabase(isInitial: false),
              color: const Color(0xFF114177),
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Text(
                    'Peringkat Kontribusi Seluruh Lokasi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                  ),
                  const SizedBox(height: 10),

                  // List Seluruh Lokasi
                  ..._locations.map((loc) => _buildLocationCard(loc)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildLocationCard(Map<String, dynamic> loc) {
    final int rank = loc['rank'] as int;
    final double pct = loc['percentage'] as double;
    final String pctText = '${(pct * 100).toStringAsFixed(1)}%';

    Color rankColor;
    Color rankBg;
    if (rank == 1) {
      rankColor = const Color(0xFFD97706);
      rankBg = const Color(0xFFFEF3C7);
    } else if (rank == 2) {
      rankColor = const Color(0xFF4B5563);
      rankBg = const Color(0xFFE5E7EB);
    } else if (rank == 3) {
      rankColor = const Color(0xFFB45309);
      rankBg = const Color(0xFFFFEDD5);
    } else {
      rankColor = const Color(0xFF114177);
      rankBg = const Color(0xFFF3F4F6);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rank <= 3 ? rankColor.withValues(alpha: 0.3) : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Badge Peringkat
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: rankBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#$rank',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: rankColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc['name'],
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                    ),
                    Text(
                      '${loc['city']} • ${loc['sessions']}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    loc['omzet'],
                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                  ),
                  Text(
                    loc['growth'],
                    style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF17A18A)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress Bar Kontribusi
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: AlwaysStoppedAnimation<Color>(rank <= 3 ? const Color(0xFF114177) : const Color(0xFF17A18A)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                pctText,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF45474A)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
