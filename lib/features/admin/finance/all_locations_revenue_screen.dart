import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllLocationsRevenueScreen extends StatefulWidget {
  const AllLocationsRevenueScreen({super.key});

  @override
  State<AllLocationsRevenueScreen> createState() => _AllLocationsRevenueScreenState();
}

class _AllLocationsRevenueScreenState extends State<AllLocationsRevenueScreen> {
  bool _isLoading = false;

  // Dataset semua lokasi parkir
  final List<Map<String, dynamic>> _locations = [
    {
      'rank': 1,
      'name': 'Central Park Mall',
      'city': 'Jakarta Barat',
      'address': 'Jl. Letjen S. Parman No. 28, Tanjung Duren',
      'omzet': 'Rp 156.400.000',
      'rawAmount': 156400000,
      'percentage': 0.415,
      'sessions': '4.120 sesi',
      'growth': '+16.5%',
    },
    {
      'rank': 2,
      'name': 'Grand Indonesia',
      'city': 'Jakarta Pusat',
      'address': 'Jl. M.H. Thamrin No. 1, Menteng',
      'omzet': 'Rp 98.250.000',
      'rawAmount': 98250000,
      'percentage': 0.261,
      'sessions': '2.640 sesi',
      'growth': '+14.1%',
    },
    {
      'rank': 3,
      'name': 'Malioboro Mall',
      'city': 'Yogyakarta',
      'address': 'Jl. Malioboro No. 52-58, Danurejan',
      'omzet': 'Rp 34.600.000',
      'rawAmount': 34600000,
      'percentage': 0.092,
      'sessions': '1.180 sesi',
      'growth': '+8.4%',
    },
    {
      'rank': 4,
      'name': 'Galaxy Mall Surabaya',
      'city': 'Surabaya',
      'address': 'Jl. Dharmahusada Indah Timur No. 35-37',
      'omzet': 'Rp 23.200.000',
      'rawAmount': 23200000,
      'percentage': 0.062,
      'sessions': '790 sesi',
      'growth': '+7.2%',
    },
    {
      'rank': 5,
      'name': 'Paris Van Java',
      'city': 'Bandung',
      'address': 'Jl. Sukajadi No. 131-139, Cipedes',
      'omzet': 'Rp 18.500.000',
      'rawAmount': 18500000,
      'percentage': 0.049,
      'sessions': '620 sesi',
      'growth': '+6.2%',
    },
    {
      'rank': 6,
      'name': 'Mall Bali Galeria',
      'city': 'Denpasar, Bali',
      'address': 'Jl. Bypass Ngurah Rai, Kuta',
      'omzet': 'Rp 14.200.000',
      'rawAmount': 14200000,
      'percentage': 0.038,
      'sessions': '480 sesi',
      'growth': '+5.5%',
    },
    {
      'rank': 7,
      'name': 'Sun Plaza',
      'city': 'Medan',
      'address': 'Jl. KH. Zainul Arifin No. 7, Petisah',
      'omzet': 'Rp 11.800.000',
      'rawAmount': 11800000,
      'percentage': 0.031,
      'sessions': '390 sesi',
      'growth': '+4.8%',
    },
    {
      'rank': 8,
      'name': 'Living World Alam Sutera',
      'city': 'Tangerang Selatan',
      'address': 'Jl. Alam Sutera Boulevard Kav. 21',
      'omzet': 'Rp 9.400.000',
      'rawAmount': 9400000,
      'percentage': 0.025,
      'sessions': '310 sesi',
      'growth': '+4.1%',
    },
    {
      'rank': 9,
      'name': 'Pakuwon Mall',
      'city': 'Surabaya Barat',
      'address': 'Jl. Mayjend. Jonosewojo No. 2, Babatan',
      'omzet': 'Rp 8.100.000',
      'rawAmount': 8100000,
      'percentage': 0.022,
      'sessions': '270 sesi',
      'growth': '+3.9%',
    },
    {
      'rank': 10,
      'name': 'Solo Paragon Mall',
      'city': 'Surakarta',
      'address': 'Jl. Yosodipuro No. 133, Mangkubumen',
      'omzet': 'Rp 6.500.000',
      'rawAmount': 6500000,
      'percentage': 0.017,
      'sessions': '210 sesi',
      'growth': '+2.8%',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Memanggil database hanya sekali saat halaman dibuka
    _fetchFromDatabase(isInitial: true);
  }

  Future<void> _fetchFromDatabase({bool isInitial = false}) async {
    setState(() => _isLoading = true);

    // Simulasi pemanggilan query data lokasi dari database
    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (!isInitial) {
      ScaffoldMessenger.of(context).showSnackBar(
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
