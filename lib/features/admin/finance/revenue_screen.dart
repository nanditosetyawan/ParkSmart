import 'dart:math' as math;
import 'all_locations_revenue_screen.dart';
import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'backend/revenue_backend.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // State untuk Tab 1: Ringkasan (Pendapatan Kuartal)
  int? _inspectedQuarterIndex;
  List<double> get _quarterlyChartData => RevenueBackend.instance.quarterlyChartData;
  List<String> get _quarterlyValues => RevenueBackend.instance.quarterlyValues;
  List<String> get _quarterlyDates => RevenueBackend.instance.quarterlyDates;
  List<double> get _quarterlyGrowths => RevenueBackend.instance.quarterlyGrowths;
  List<String> get _quarterlyXLabels => RevenueBackend.instance.quarterlyXLabels;
  int get _availableQuartersCount => RevenueBackend.instance.availableQuartersCount;
  int get _latestQuarterIndex => RevenueBackend.instance.latestQuarterIndex;


  // State untuk Tab 2: Per Lokasi
  String? _selectedLocation;
  String _selectedPeriod = '1 Bulan'; // '1 Bulan', '1 Tahun'
  int? _inspectedLocationIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    RevenueBackend.instance.fetchRevenueData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onQuarterChartTouch(double localX, double canvasWidth, int pointCount, int activeCount) {
    if (pointCount <= 1 || canvasWidth <= 0 || activeCount <= 0) return;
    const double marginHorizontal = 24.0;
    final double chartWidth = canvasWidth - (marginHorizontal * 2);
    if (chartWidth <= 0) return;
    final double stepX = chartWidth / (pointCount - 1);
    final double relativeX = (localX - marginHorizontal).clamp(0.0, chartWidth);
    final int closestIndex = (relativeX / stepX).round().clamp(0, activeCount - 1);
    if (_inspectedQuarterIndex != closestIndex) {
      setState(() => _inspectedQuarterIndex = closestIndex);
    }
  }

  void _onLocationChartTouch(double localX, double canvasWidth, int pointCount, int activeCount) {
    if (pointCount <= 1 || canvasWidth <= 0 || activeCount <= 0) return;
    const double marginHorizontal = 24.0;
    final double chartWidth = canvasWidth - (marginHorizontal * 2);
    if (chartWidth <= 0) return;
    final double stepX = chartWidth / (pointCount - 1);
    final double relativeX = (localX - marginHorizontal).clamp(0.0, chartWidth);
    final int closestIndex = (relativeX / stepX).round().clamp(0, activeCount - 1);
    if (_inspectedLocationIndex != closestIndex) {
      setState(() => _inspectedLocationIndex = closestIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RevenueBackend.instance,
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
              // Judul Utuh tanpa titik-titik & tanpa deskripsi di bawahnya
              title: Text(
                'Analitik Pendapatan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A18),
                ),
              ),
              // Tanpa tombol 'Bulan Ini' di kanan atas sesuai instruksi
              actions: [
                IconButton(
                  onPressed: () {
                    RevenueBackend.instance.fetchRevenueData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Memperbarui data pendapatan...', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                        backgroundColor: const Color(0xFF114177),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF114177)),
                  tooltip: 'Perbarui Data',
                ),
                const SizedBox(width: 4),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF114177),
                unselectedLabelColor: const Color(0xFF76777B),
                indicatorColor: const Color(0xFF114177),
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'Ringkasan'),
                  Tab(text: 'Per Lokasi'),
                  Tab(text: 'Jenis'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildPerLocationTab(),
                _buildVehicleTypeTab(),
              ],
            ),
          ),
        );
      },
    );
  }


  // ==================== TAB 1: RINGKASAN (PENDAPATAN PER KUARTAL) ====================
  Widget _buildSummaryTab() {
    final int activeIdx = (_inspectedQuarterIndex ?? _latestQuarterIndex).clamp(0, _quarterlyValues.length - 1);
    final String displayOmzet = _quarterlyValues[activeIdx];
    final String displayDate = _quarterlyDates[activeIdx];
    final double growth = _quarterlyGrowths[activeIdx];
    final bool isNegative = growth < 0;
    final String growthText = activeIdx == 0
        ? 'Kuartal 1 (Basis)'
        : '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}% vs Q$activeIdx';

    return RefreshIndicator(
      onRefresh: () => RevenueBackend.instance.fetchRevenueData(),
      color: const Color(0xFF114177),
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Kartu Utama: Pendapatan Per Kuartal & Chart Gunung
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF114177).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.pie_chart_rounded, size: 22, color: Color(0xFF114177)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PENDAPATAN PER KUARTAL',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF76777B),
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          'Tren Kinerja Kuartal (${RevenueBackend.instance.dynamicYear})',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Nilai Nominal Besar Dinamis
              Text(
                displayOmzet,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF114177),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayDate,
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isNegative ? const Color(0xFFFDE8E4) : const Color(0xFFE8F7F4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isNegative
                        ? const Color(0xFFD94B4B).withValues(alpha: 0.25)
                        : const Color(0xFF17A18A).withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isNegative ? Icons.trending_down : Icons.trending_up,
                      size: 12,
                      color: isNegative ? const Color(0xFFD94B4B) : const Color(0xFF17A18A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      growthText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isNegative ? const Color(0xFFD94B4B) : const Color(0xFF17A18A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ⛰️ Smooth Mountain Chart Pendapatan Kuartalan
              LayoutBuilder(
                builder: (context, constraints) {
                  final double canvasWidth = constraints.maxWidth;
                  const double canvasHeight = 160.0;
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) => _onQuarterChartTouch(details.localPosition.dx, canvasWidth, _quarterlyChartData.length, _availableQuartersCount),
                        onPanStart: (details) => _onQuarterChartTouch(details.localPosition.dx, canvasWidth, _quarterlyChartData.length, _availableQuartersCount),
                        onPanUpdate: (details) => _onQuarterChartTouch(details.localPosition.dx, canvasWidth, _quarterlyChartData.length, _availableQuartersCount),
                        child: SizedBox(
                          width: canvasWidth,
                          height: canvasHeight,
                          child: CustomPaint(
                            painter: _MountainChartPainter(
                              data: _quarterlyChartData,
                              pointValues: _quarterlyValues,
                              pointDates: _quarterlyDates,
                              xLabels: _quarterlyXLabels,
                              inspectedIndex: _inspectedQuarterIndex,
                              activePointCount: _availableQuartersCount,
                              lineColor: const Color(0xFF114177),
                              gradientStart: const Color(0xFF114177).withValues(alpha: 0.35),
                              gradientEnd: const Color(0xFF114177).withValues(alpha: 0.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Rincian Riwayat Pendapatan Kuartalan
        Text(
          'Rekapitulasi Kuartal',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
        ),
        const SizedBox(height: 10),

        // Rincian Riwayat Pendapatan Kuartalan Dinamis
        ...RevenueBackend.instance.displayedQuarterIndices.map((qIdx) {
          final isCurrent = qIdx == RevenueBackend.instance.currentQuarterIndex;
          final growthVal = _quarterlyGrowths[qIdx];
          final growthLabel = qIdx == 0
              ? 'Basis Data'
              : '${growthVal >= 0 ? '+' : ''}${growthVal.toStringAsFixed(1)}%';

          return _buildMonthlyRecapCard(
            _quarterlyDates[qIdx],
            _quarterlyValues[qIdx],
            growthLabel,
            '${RevenueBackend.instance.quarterlyTrxCounts[qIdx]} transaksi',
            isCurrent ? const Color(0xFF114177) : const Color(0xFF45474A),
            isCurrent: isCurrent,
            isDrop: growthVal < 0,
          );
        }),
        const SizedBox(height: 18),

        // Kontribusi Omzet per Lokasi (Terkoneksi Dinamis ke Database)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kontribusi Omzet per Lokasi', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      Text(
                        RevenueBackend.instance.top4Locations.isNotEmpty
                            ? '${RevenueBackend.instance.top4Locations.length} Lokasi Teratas • Real-time'
                            : '0 Lokasi • Real-time',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllLocationsRevenueScreen())),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Semua',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF114177),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (RevenueBackend.instance.top4Locations.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.location_city_outlined, size: 22, color: Color(0xFF76777B)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Belum Ada Kontribusi Lokasi',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Belum ada riwayat omzet lokasi parkir tercatat di database',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                ...RevenueBackend.instance.top4Locations.map((loc) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildLocationMiniRow(
                      loc['name']?.toString() ?? 'Lokasi',
                      loc['city']?.toString() ?? '-',
                      loc['omzet']?.toString() ?? 'Rp 0',
                      (loc['ratio'] as num?)?.toDouble() ?? 0.0,
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    ),
  );
}

  Widget _buildLocationMiniRow(String name, String city, String amount, double ratio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                Text(city, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF76777B))),
              ],
            ),
            Text(amount, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: const Color(0xFFF3F4F6),
            valueColor: AlwaysStoppedAnimation<Color>(ratio >= 0.7 ? const Color(0xFF114177) : const Color(0xFF17A18A)),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyRecapCard(String month, String total, String growth, String trxCount, Color color, {bool isCurrent = false, bool isDrop = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isCurrent ? const Color(0xFF114177).withValues(alpha: 0.3) : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFF114177).withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.event_note_rounded, size: 20, color: isCurrent ? const Color(0xFF114177) : const Color(0xFF76777B)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(month, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      if (isCurrent) ...[
                        const SizedBox(width: 6),
                        Container(
                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF114177), borderRadius: BorderRadius.circular(4)),
                          child: Text('Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                  Text(trxCount, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(total, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
              Text(
                growth,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDrop ? const Color(0xFFD94B4B) : const Color(0xFF17A18A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: PER LOKASI ====================
  Widget _buildPerLocationTab() {
    final backend = RevenueBackend.instance;
    final locationOptions = backend.availableLocations
        .map((l) => (l['name'] ?? '').toString())
        .where((n) => n.isNotEmpty)
        .toList();

    // 1. Kondisi jika TIDAK ADA LOKASI di database
    if (locationOptions.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown menampilkan "Tidak Ada Lokasi Parkir"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_off, size: 16, color: Color(0xFF76777B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tidak Ada Lokasi Parkir',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF76777B),
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF76777B)),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_off_outlined, size: 28, color: Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Tidak Ada Lokasi Parkir',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A18),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Belum ada data lokasi parkir di database.\nData analitik per lokasi akan tampil saat lokasi terdaftar.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF76777B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      );
    }

    // 2. Jika ada lokasi, tentukan lokasi yang terpilih
    final String currentLoc = (_selectedLocation != null && locationOptions.contains(_selectedLocation))
        ? _selectedLocation!
        : locationOptions.first;

    final locData = backend.locationDataset[currentLoc] ?? {
      'totalOmzet': 'Rp 0',
      'contribution': '0.0%',
      'city': '',
      'code': '',
      // 1 Bulan
      'monthData': [0.08, 0.08, 0.08, 0.08],
      'monthValues': ['Rp 0', 'Rp 0', 'Rp 0', 'Rp 0'],
      'monthDates': ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4'],
      'monthLabels': ['W1', 'W2', 'W3', 'W4'],
      'monthGrowths': [0.0, 0.0, 0.0, 0.0],
      // 1 Tahun (4 Kuartal)
      'yearData': [0.08, 0.08, 0.08, 0.08],
      'yearValues': ['Rp 0', 'Rp 0', 'Rp 0', 'Rp 0'],
      'yearDates': ['Q1', 'Q2', 'Q3', 'Q4'],
      'yearLabels': ['Q1', 'Q2', 'Q3', 'Q4'],
      'yearGrowths': [0.0, 0.0, 0.0, 0.0],
    };

    List<double> currentChartData;
    List<String> currentValues;
    List<String> currentDates;
    List<String> currentLabels;
    List<double> currentGrowths;
    int activePointCount;
    int latestPointIndex;

    if (_selectedPeriod == '1 Tahun') {
      // 1 Tahun = Per Kuartal (Q1, Q2, Q3, Q4)
      currentChartData = List<double>.from(locData['yearData'] ?? [0.08, 0.08, 0.08, 0.08]);
      currentValues = List<String>.from(locData['yearValues'] ?? ['Rp 0', 'Rp 0', 'Rp 0', 'Rp 0']);
      currentDates = List<String>.from(locData['yearDates'] ?? ['Q1', 'Q2', 'Q3', 'Q4']);
      currentLabels = List<String>.from(locData['yearLabels'] ?? ['Q1', 'Q2', 'Q3', 'Q4']);
      currentGrowths = List<double>.from(locData['yearGrowths'] ?? [0.0, 0.0, 0.0, 0.0]);
      activePointCount = backend.availableQuartersCount;
      latestPointIndex = backend.latestQuarterIndex;
    } else {
      // 1 Bulan = Per Minggu (W1, W2, W3, W4)
      currentChartData = List<double>.from(locData['monthData'] ?? [0.08, 0.08, 0.08, 0.08]);
      currentValues = List<String>.from(locData['monthValues'] ?? ['Rp 0', 'Rp 0', 'Rp 0', 'Rp 0']);
      currentDates = List<String>.from(locData['monthDates'] ?? ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4']);
      currentLabels = List<String>.from(locData['monthLabels'] ?? ['W1', 'W2', 'W3', 'W4']);
      currentGrowths = List<double>.from(locData['monthGrowths'] ?? [0.0, 0.0, 0.0, 0.0]);
      activePointCount = backend.availableWeeksCount;
      latestPointIndex = backend.latestWeekIndex;
    }

    final int effectiveActive = activePointCount.clamp(1, currentValues.length);
    final int activeIdx = (_inspectedLocationIndex ?? latestPointIndex).clamp(0, effectiveActive - 1);
    final String displayNominal = currentValues[activeIdx];
    final String displayDate = currentDates[activeIdx];
    final double growth = currentGrowths[activeIdx];
    final bool isNegative = growth < 0;
    final String growthText = activeIdx == 0
        ? (_selectedPeriod == '1 Tahun' ? 'Kuartal 1 (Basis)' : 'Minggu 1 (Basis)')
        : '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}% vs ${currentLabels[activeIdx - 1]}';

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Kartu Utama: Chart Per Lokasi dengan Dropdown & Tombol Periode (Hanya 1 Bulan dan 1 Tahun)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Dropdown Pilih Lokasi Dinamis dari Database
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currentLoc,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF114177)),
                    items: locationOptions.map((loc) {
                      return DropdownMenuItem(
                        value: loc,
                        child: Row(
                          children: [
                            const Icon(Icons.place, size: 16, color: Color(0xFF114177)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                loc,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A18),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _selectedLocation = v;
                          _inspectedLocationIndex = null;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Tombol Pilihan Periode (HANYA 1 Bulan dan 1 Tahun - Tab 2 Tahun Dihilangkan)
              Row(
                children: ['1 Bulan', '1 Tahun'].map((p) {
                  final isSelected = _selectedPeriod == p;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPeriod = p;
                            _inspectedLocationIndex = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF114177) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            p,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF76777B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Nilai Nominal Besar Dinamis (Default ke data terbaru, berubah saat titik disentuh)
              Text(
                displayNominal,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF114177),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Titik Waktu: $displayDate (Sentuh titik lain pada grafik)',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
              ),
              const SizedBox(height: 6),

              // Badge Persentase Kenaikan / Penurunan vs Titik Sebelumnya
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: activeIdx == 0
                      ? const Color(0xFFF3F4F6)
                      : (isNegative ? const Color(0xFFFDE8E4) : const Color(0xFFE8F7F4)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: activeIdx == 0
                        ? const Color(0xFFE5E7EB)
                        : (isNegative
                            ? const Color(0xFFD94B4B).withValues(alpha: 0.25)
                            : const Color(0xFF17A18A).withValues(alpha: 0.25)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      activeIdx == 0
                          ? Icons.info_outline
                          : (isNegative ? Icons.trending_down : Icons.trending_up),
                      size: 12,
                      color: activeIdx == 0
                          ? const Color(0xFF76777B)
                          : (isNegative ? const Color(0xFFD94B4B) : const Color(0xFF17A18A)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      growthText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: activeIdx == 0
                            ? const Color(0xFF76777B)
                            : (isNegative ? const Color(0xFFD94B4B) : const Color(0xFF17A18A)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ⛰️ Smooth Mountain Chart Per Lokasi
              LayoutBuilder(
                builder: (context, constraints) {
                  final double canvasWidth = constraints.maxWidth;
                  const double canvasHeight = 160.0;
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) => _onLocationChartTouch(details.localPosition.dx, canvasWidth, currentChartData.length, effectiveActive),
                        onPanStart: (details) => _onLocationChartTouch(details.localPosition.dx, canvasWidth, currentChartData.length, effectiveActive),
                        onPanUpdate: (details) => _onLocationChartTouch(details.localPosition.dx, canvasWidth, currentChartData.length, effectiveActive),
                        child: SizedBox(
                          width: canvasWidth,
                          height: canvasHeight,
                          child: CustomPaint(
                            painter: _MountainChartPainter(
                              data: currentChartData,
                              pointValues: currentValues,
                              pointDates: currentDates,
                              xLabels: currentLabels,
                              inspectedIndex: _inspectedLocationIndex,
                              activePointCount: effectiveActive,
                              lineColor: const Color(0xFF17A18A),
                              gradientStart: const Color(0xFF17A18A).withValues(alpha: 0.35),
                              gradientEnd: const Color(0xFF17A18A).withValues(alpha: 0.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Kartu Ringkasan Info Lokasi
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Kinerja $currentLoc',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem('Total Omzet 2026', locData['totalOmzet'] ?? 'Rp 0', const Color(0xFF114177)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoItem('Kontribusi Omzet', locData['contribution'] ?? '0.0%', const Color(0xFF17A18A)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  // ==================== TAB 3: JENIS (PENDAPATAN TIPE KENDARAAN) ====================
  Widget _buildVehicleTypeTab() {
    final backend = RevenueBackend.instance;
    final int totalSessions = backend.totalCompletedSessions;
    final double totalRevenue = backend.totalCompletedRevenue;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Judul Isi: Pendapatan Tipe Kendaraan
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pendapatan Tipe Kendaraan',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                ),
                Text(
                  'Fokus kategori kendaraan Mobil dan Motor',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Banner Status: Khusus Sesi Parkir Selesai (Completed)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF114177).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF114177).withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF114177)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Data global seluruh lokasi • Hanya menghitung sesi parkir selesai (sesi aktif/proses dikecualikan)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF114177),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (totalSessions == 0) ...[
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                const Icon(Icons.directions_car_outlined, size: 44, color: Color(0xFF9CA3AF)),
                const SizedBox(height: 12),
                Text(
                  'Belum Ada Sesi Parkir Selesai',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Data rasio kendaraan akan otomatis muncul saat sesi parkir berstatus completed tercatat di database.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
                ),
              ],
            ),
          ),
        ] else ...[
          // Kartu 1: Rasio Kontribusi Omzet (Sesuai Desain Asli dengan Data Real)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rasio Kontribusi Omzet',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                    ),
                    Text(
                      'Total Rp ${_formatCurrency(totalRevenue.round())}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      if (backend.completedMobilRevenue > 0)
                        Expanded(
                          flex: backend.mobilRevenueRatio.round().clamp(1, 100),
                          child: Container(
                            height: 12,
                            color: const Color(0xFF114177),
                          ),
                        ),
                      if (backend.completedMobilRevenue > 0 && backend.completedMotorRevenue > 0)
                        const SizedBox(width: 2),
                      if (backend.completedMotorRevenue > 0)
                        Expanded(
                          flex: backend.motorRevenueRatio.round().clamp(1, 100),
                          child: Container(
                            height: 12,
                            color: const Color(0xFF17A18A),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF114177), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(
                          'Mobil (${backend.mobilRevenueRatio.toStringAsFixed(1)}%)',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF114177)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF17A18A), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(
                          'Motor (${backend.motorRevenueRatio.toStringAsFixed(1)}%)',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF17A18A)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Kartu 2: Rata-rata Tipe Kendaraan Selesai (Berdasarkan Volume Sesi Mobil vs Motor)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rata-rata Kendaraan Selesai',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                    ),
                    Text(
                      'Total ${_formatNumber(totalSessions)} Sesi',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      if (backend.completedMobilCount > 0)
                        Expanded(
                          flex: backend.mobilSessionRatio.round().clamp(1, 100),
                          child: Container(
                            height: 12,
                            color: const Color(0xFF114177),
                          ),
                        ),
                      if (backend.completedMobilCount > 0 && backend.completedMotorCount > 0)
                        const SizedBox(width: 2),
                      if (backend.completedMotorCount > 0)
                        Expanded(
                          flex: backend.motorSessionRatio.round().clamp(1, 100),
                          child: Container(
                            height: 12,
                            color: const Color(0xFF17A18A),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF114177), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(
                          'Mobil (${backend.mobilSessionRatio.toStringAsFixed(1)}%) • ${_formatNumber(backend.completedMobilCount)} Sesi',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF114177)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF17A18A), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(
                          'Motor (${backend.motorSessionRatio.toStringAsFixed(1)}%) • ${_formatNumber(backend.completedMotorCount)} Sesi',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF17A18A)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Kartu 3: Komparasi Detail Mobil vs Motor
          Row(
            children: [
              Expanded(
                child: _buildVehicleDetailCard(
                  title: 'Mobil',
                  icon: Icons.directions_car_rounded,
                  iconColor: const Color(0xFF114177),
                  sessionCount: backend.completedMobilCount,
                  revenue: backend.completedMobilRevenue,
                  avgFee: backend.avgFeeMobil,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVehicleDetailCard(
                  title: 'Motor',
                  icon: Icons.two_wheeler_rounded,
                  iconColor: const Color(0xFF17A18A),
                  sessionCount: backend.completedMotorCount,
                  revenue: backend.completedMotorRevenue,
                  avgFee: backend.avgFeeMotor,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildVehicleDetailCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required int sessionCount,
    required double revenue,
    required double avgFee,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Sesi Selesai', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF76777B))),
          Text('${_formatNumber(sessionCount)} transaksi', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          const SizedBox(height: 8),
          Text('Total Pendapatan', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF76777B))),
          Text('Rp ${_formatCurrency(revenue.round())}', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: iconColor)),
          const SizedBox(height: 8),
          Text('Rata-rata / Sesi', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF76777B))),
          Text('Rp ${_formatCurrency(avgFee.round())}', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF45474A))),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  String _formatCurrency(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}

// ─── CUSTOM PAINTER: SMOOTH MOUNTAIN AREA CHART (TRADING STYLE) ───
class _MountainChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> pointValues;
  final List<String> pointDates;
  final List<String> xLabels;
  final int? inspectedIndex;
  final int activePointCount;
  final Color lineColor;
  final Color gradientStart;
  final Color gradientEnd;

  _MountainChartPainter({
    required this.data,
    required this.pointValues,
    required this.pointDates,
    required this.xLabels,
    this.inspectedIndex,
    this.activePointCount = 4,
    required this.lineColor,
    required this.gradientStart,
    required this.gradientEnd,
  });

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint, {
    double dashWidth = 4,
    double dashSpace = 4,
  }) {
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double distance = math.sqrt(dx * dx + dy * dy);
    if (distance == 0) return;
    final double unitX = dx / distance;
    final double unitY = dy / distance;

    double current = 0;
    while (current < distance) {
      final double start = current;
      final double end = math.min(current + dashWidth, distance);
      canvas.drawLine(
        Offset(p1.dx + unitX * start, p1.dy + unitY * start),
        Offset(p1.dx + unitX * end, p1.dy + unitY * end),
        paint,
      );
      current += dashWidth + dashSpace;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const double marginHorizontal = 24.0;
    final double chartWidth = size.width - (marginHorizontal * 2);
    final double stepX = chartWidth / (data.length - 1);
    const double topPadding = 24.0;
    final double baselineY = size.height - 34.0;
    final double availableHeight = baselineY - topPadding;

    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final double x = marginHorizontal + (i * stepX);
      final double y = topPadding + (1.0 - data[i].clamp(0.0, 1.0)) * availableHeight;
      points.add(Offset(x, y));
    }

    final int effectiveActive = activePointCount.clamp(1, points.length);

    // Gridlines Horizontal
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB).withValues(alpha: 0.8)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final double y = topPadding + (availableHeight / 4) * i;
      _drawDashedLine(canvas, Offset(marginHorizontal, y), Offset(size.width - marginHorizontal, y), gridPaint);
    }

    // Baseline Line
    final basePaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(marginHorizontal, baselineY), Offset(size.width - marginHorizontal, baselineY), basePaint);

    // 🌊 Path Curve & Gradient Fill (Hanya sampai kuartal aktif)
    final Path linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < effectiveActive - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    final Path fillPath = Path.from(linePath);
    fillPath.lineTo(points[effectiveActive - 1].dx, baselineY);
    fillPath.lineTo(points.first.dx, baselineY);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientStart, gradientEnd],
      ).createShader(Rect.fromLTRB(0, topPadding, 0, baselineY));

    canvas.drawPath(fillPath, fillPaint);

    // 〰️ Garis Biru Tua Utama
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // Garis putus-putus untuk kuartal yang belum berlangsung
    if (effectiveActive < points.length) {
      final futurePaint = Paint()
        ..color = const Color(0xFFD1D5DB)
        ..strokeWidth = 1.5;
      for (int i = effectiveActive - 1; i < points.length - 1; i++) {
        _drawDashedLine(canvas, points[i], points[i + 1], futurePaint);
      }
      for (int i = effectiveActive; i < points.length; i++) {
        canvas.drawCircle(points[i], 3.0, Paint()..color = const Color(0xFFD1D5DB));
      }
    }

    // Draw Points & Labels
    final activeIndex = inspectedIndex ?? (effectiveActive - 1);

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final bool isCurrent = i == activeIndex;
      final bool isFuture = i >= effectiveActive;

      if (isCurrent && !isFuture) {
        // Vertical indicator dashed line
        final indicatorPaint = Paint()
          ..color = lineColor.withValues(alpha: 0.6)
          ..strokeWidth = 1.5;
        _drawDashedLine(canvas, Offset(p.dx, topPadding), Offset(p.dx, baselineY), indicatorPaint, dashWidth: 3, dashSpace: 3);

        // Glow ring
        final glowPaint = Paint()..color = lineColor.withValues(alpha: 0.2);
        canvas.drawCircle(p, 10.0, glowPaint);

        // Solid dot
        final outerDot = Paint()..color = Colors.white;
        canvas.drawCircle(p, 5.0, outerDot);

        final innerDot = Paint()..color = lineColor;
        canvas.drawCircle(p, 3.5, innerDot);
      } else if (!isFuture) {
        final dotPaint = Paint()..color = lineColor;
        canvas.drawCircle(p, 2.5, dotPaint);
      }

      // X-Axis text
      if (i < xLabels.length) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: xLabels[i],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              color: isCurrent
                  ? lineColor
                  : isFuture
                      ? const Color(0xFFB0B0B0)
                      : const Color(0xFF76777B),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(p.dx - (textPainter.width / 2), baselineY + 8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MountainChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.inspectedIndex != inspectedIndex ||
        oldDelegate.activePointCount != activePointCount ||
        oldDelegate.lineColor != lineColor;
  }
}