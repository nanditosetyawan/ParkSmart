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

  // State untuk Tab 1: Ringkasan (Pendapatan Bulanan)
  int? _inspectedMonthlyIndex;
  List<double> get _monthlyChartData => RevenueBackend.instance.monthlyChartData;
  List<String> get _monthlyValues => RevenueBackend.instance.monthlyValues;
  List<String> get _monthlyDates => RevenueBackend.instance.monthlyDates;
  List<String> get _monthlyGrowths => RevenueBackend.instance.monthlyGrowths;
  List<String> get _monthlyXLabels => RevenueBackend.instance.monthlyXLabels;


  // State untuk Tab 2: Per Lokasi
  String _selectedLocation = 'Central Park Mall';
  String _selectedPeriod = '1 Bulan'; // '1 Bulan', '1 Tahun', '2 Tahun'
  int? _inspectedLocationIndex;

  final List<String> _locationOptions = [
    'Central Park Mall',
    'Grand Indonesia',
    'Malioboro Mall',
    'Paris Van Java',
  ];

  final Map<String, Map<String, dynamic>> _locationDataset = {
    'Central Park Mall': {
      'totalOmzet': 'Rp 156.400.000',
      'contribution': '50.1%',
      'dailyAvg': 'Rp 5.213.000',
      'occupancy': '84.2%',
      'growth': '+16.5%',
      // 1 Bulan
      'monthData': [0.50, 0.65, 0.78, 0.95],
      'monthValues': ['Rp 34.2 jt', 'Rp 38.5 jt', 'Rp 41.2 jt', 'Rp 42.5 jt'],
      'monthDates': ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4'],
      'monthLabels': ['W1', 'W2', 'W3', 'W4'],
      // 1 Tahun
      'yearData': [0.40, 0.48, 0.58, 0.70, 0.82, 0.95],
      'yearValues': ['Rp 110 jt', 'Rp 122 jt', 'Rp 135 jt', 'Rp 142 jt', 'Rp 150 jt', 'Rp 156.4 jt'],
      'yearDates': ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt'],
      'yearLabels': ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt'],
      // 2 Tahun
      'twoYearData': [0.35, 0.45, 0.60, 0.75, 0.88, 0.98],
      'twoYearValues': ['Rp 85 jt', 'Rp 102 jt', 'Rp 120 jt', 'Rp 138 jt', 'Rp 148 jt', 'Rp 156.4 jt'],
      'twoYearDates': ['Q1 25', 'Q2 25', 'Q3 25', 'Q4 25', 'Q1 26', 'Q2-Q3 26'],
      'twoYearLabels': ['Q1 25', 'Q2 25', 'Q3 25', 'Q4 25', 'Q1 26', 'Q3 26'],
    },
    'Grand Indonesia': {
      'totalOmzet': 'Rp 98.250.000',
      'contribution': '31.4%',
      'dailyAvg': 'Rp 3.275.000',
      'occupancy': '79.6%',
      'growth': '+14.1%',
      'monthData': [0.45, 0.58, 0.72, 0.88],
      'monthValues': ['Rp 21.0 jt', 'Rp 24.2 jt', 'Rp 26.0 jt', 'Rp 27.05 jt'],
      'monthDates': ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4'],
      'monthLabels': ['W1', 'W2', 'W3', 'W4'],
      'yearData': [0.38, 0.45, 0.55, 0.68, 0.78, 0.90],
      'yearValues': ['Rp 68 jt', 'Rp 75 jt', 'Rp 82 jt', 'Rp 89 jt', 'Rp 94 jt', 'Rp 98.25 jt'],
      'yearDates': ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt'],
      'yearLabels': ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt'],
      'twoYearData': [0.30, 0.40, 0.52, 0.68, 0.80, 0.92],
      'twoYearValues': ['Rp 55 jt', 'Rp 65 jt', 'Rp 74 jt', 'Rp 84 jt', 'Rp 92 jt', 'Rp 98.25 jt'],
      'twoYearDates': ['Q1 25', 'Q2 25', 'Q3 25', 'Q4 25', 'Q1 26', 'Q3 26'],
      'twoYearLabels': ['Q1 25', 'Q2 25', 'Q3 25', 'Q4 25', 'Q1 26', 'Q3 26'],
    },
    'Malioboro Mall': {
      'totalOmzet': 'Rp 34.600.000',
      'contribution': '11.1%',
      'dailyAvg': 'Rp 1.153.000',
      'occupancy': '68.0%',
      'growth': '+8.4%',
      'monthData': [0.40, 0.50, 0.60, 0.75],
      'monthValues': ['Rp 7.5 jt', 'Rp 8.6 jt', 'Rp 9.1 jt', 'Rp 9.4 jt'],
      'monthDates': ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4'],
      'monthLabels': ['W1', 'W2', 'W3', 'W4'],
      'yearData': [0.35, 0.42, 0.48, 0.58, 0.65, 0.75],
      'yearValues': ['Rp 22 jt', 'Rp 25 jt', 'Rp 27 jt', 'Rp 30 jt', 'Rp 32 jt', 'Rp 34.6 jt'],
      'yearDates': ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt'],
      'yearLabels': ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt'],
      'twoYearData': [0.28, 0.35, 0.45, 0.55, 0.65, 0.78],
      'twoYearValues': ['Rp 18 jt', 'Rp 21 jt', 'Rp 25 jt', 'Rp 28 jt', 'Rp 31 jt', 'Rp 34.6 jt'],
      'twoYearDates': ['Q1 25', 'Q2 25', 'Q3 25', 'Q4 25', 'Q1 26', 'Q3 26'],
      'twoYearLabels': ['Q1 25', 'Q2 25', 'Q3 25', 'Q4 25', 'Q1 26', 'Q3 26'],
    },
    'Paris Van Java': {
      'totalOmzet': 'Rp 23.200.000',
      'contribution': '7.4%',
      'dailyAvg': 'Rp 773.000',
      'occupancy': '62.5%',
      'growth': '+6.2%',
      'monthData': [0.35, 0.45, 0.55, 0.68],
      'monthValues': ['Rp 5.1 jt', 'Rp 5.8 jt', 'Rp 6.0 jt', 'Rp 6.3 jt'],
      'monthDates': ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4'],
      'monthLabels': ['W1', 'W2', 'W3', 'W4'],
      'yearData': [0.30, 0.38, 0.44, 0.52, 0.60, 0.70],
      'yearValues': ['Rp 14 jt', 'Rp 16 jt', 'Rp 18 jt', 'Rp 20 jt', 'Rp 21 jt', 'Rp 23.2 jt'],
      'yearDates': ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt'],
      'yearLabels': ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt'],
      'twoYearData': [0.25, 0.32, 0.40, 0.48, 0.58, 0.70],
      'twoYearValues': ['Rp 11 jt', 'Rp 13 jt', 'Rp 16 jt', 'Rp 18 jt', 'Rp 20 jt', 'Rp 23.2 jt'],
      'twoYearDates': ['Q1 25', 'Q2 25', 'Q3 25', 'Q4 25', 'Q1 26', 'Q3 26'],
      'twoYearLabels': ['Q1 25', 'Q2 25', 'Q3 25', 'Q4 25', 'Q1 26', 'Q3 26'],
    },
  };

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

  void _onMonthlyChartTouch(double localX, double canvasWidth, int pointCount) {
    const double marginHorizontal = 24.0;
    final double chartWidth = canvasWidth - (marginHorizontal * 2);
    final double stepX = chartWidth / (pointCount - 1);
    final double relativeX = localX - marginHorizontal;
    int index = (relativeX / stepX).round();
    if (index < 0) index = 0;
    if (index >= pointCount) index = pointCount - 1;
    setState(() => _inspectedMonthlyIndex = index);
  }

  void _onLocationChartTouch(double localX, double canvasWidth, int pointCount) {
    const double marginHorizontal = 24.0;
    final double chartWidth = canvasWidth - (marginHorizontal * 2);
    final double stepX = chartWidth / (pointCount - 1);
    final double relativeX = localX - marginHorizontal;
    int index = (relativeX / stepX).round();
    if (index < 0) index = 0;
    if (index >= pointCount) index = pointCount - 1;
    setState(() => _inspectedLocationIndex = index);
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
              actions: const [
                SizedBox(width: 8),
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


  // ==================== TAB 1: RINGKASAN (PENDAPATAN PER BULAN) ====================
  Widget _buildSummaryTab() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Kartu Utama: Pendapatan Per Bulan & Chart Gunung
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
                    child: const Icon(Icons.calendar_month_rounded, size: 22, color: Color(0xFF114177)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PENDAPATAN PER BULAN',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF76777B),
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        'Tren Kinerja 6 Bulan Terakhir',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Nilai Nominal Besar Dinamis
              Text(
                _inspectedMonthlyIndex != null && _inspectedMonthlyIndex! < _monthlyValues.length
                    ? _monthlyValues[_inspectedMonthlyIndex!]
                    : 'Rp 312.450.000',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF114177),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _inspectedMonthlyIndex != null && _inspectedMonthlyIndex! < _monthlyDates.length
                    ? _monthlyDates[_inspectedMonthlyIndex!]
                    : 'Oktober 2026',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF17A18A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _inspectedMonthlyIndex != null && _inspectedMonthlyIndex! < _monthlyGrowths.length
                      ? _monthlyGrowths[_inspectedMonthlyIndex!]
                      : '+15.7%',
                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A)),
                ),
              ),
              const SizedBox(height: 16),

              // ⛰️ Smooth Mountain Chart Pendapatan Bulanan
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
                        onTapDown: (details) => _onMonthlyChartTouch(details.localPosition.dx, canvasWidth, _monthlyChartData.length),
                        onPanStart: (details) => _onMonthlyChartTouch(details.localPosition.dx, canvasWidth, _monthlyChartData.length),
                        onPanUpdate: (details) => _onMonthlyChartTouch(details.localPosition.dx, canvasWidth, _monthlyChartData.length),
                        child: SizedBox(
                          width: canvasWidth,
                          height: canvasHeight,
                          child: CustomPaint(
                            painter: _MountainChartPainter(
                              data: _monthlyChartData,
                              pointValues: _monthlyValues,
                              pointDates: _monthlyDates,
                              xLabels: _monthlyXLabels,
                              inspectedIndex: _inspectedMonthlyIndex,
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

        // Rincian Riwayat Pendapatan Bulanan
        Text(
          'Rekapitulasi Bulanan',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
        ),
        const SizedBox(height: 10),

        _buildMonthlyRecapCard('Oktober 2026', 'Rp 312.450.000', '+15.7%', '8.420 sesi', const Color(0xFF114177), isCurrent: true),
        _buildMonthlyRecapCard('September 2026', 'Rp 295.400.000', '+10.4%', '7.890 sesi', const Color(0xFF45474A)),
        _buildMonthlyRecapCard('Agustus 2026', 'Rp 269.800.000', '+12.1%', '7.210 sesi', const Color(0xFF45474A)),
        _buildMonthlyRecapCard('Juli 2026', 'Rp 240.500.000', '+6.5%', '6.650 sesi', const Color(0xFF45474A)),
        _buildMonthlyRecapCard('Juni 2026', 'Rp 225.800.000', '+7.2%', '6.310 sesi', const Color(0xFF45474A)),
        const SizedBox(height: 18),

        // Kontribusi Omzet per Lokasi (Default 4 Lokasi)
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
                      Text('4 Lokasi Teratas • Real-time', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
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
              _buildLocationMiniRow('Central Park Mall', 'Jakarta Barat', 'Rp 156.400.000', 0.85),
              const SizedBox(height: 10),
              _buildLocationMiniRow('Grand Indonesia', 'Jakarta Pusat', 'Rp 98.250.000', 0.72),
              const SizedBox(height: 10),
              _buildLocationMiniRow('Malioboro Mall', 'Yogyakarta', 'Rp 34.600.000', 0.40),
              const SizedBox(height: 10),
              _buildLocationMiniRow('Galaxy Mall Surabaya', 'Surabaya', 'Rp 23.200.000', 0.25),

            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
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

  Widget _buildMonthlyRecapCard(String month, String total, String growth, String trxCount, Color color, {bool isCurrent = false}) {
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
              Text(growth, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF17A18A))),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: PER LOKASI ====================
  Widget _buildPerLocationTab() {
    final locData = _locationDataset[_selectedLocation] ?? _locationDataset['Central Park Mall']!;

    List<double> currentChartData;
    List<String> currentValues;
    List<String> currentDates;
    List<String> currentLabels;

    if (_selectedPeriod == '1 Tahun') {
      currentChartData = List<double>.from(locData['yearData']);
      currentValues = List<String>.from(locData['yearValues']);
      currentDates = List<String>.from(locData['yearDates']);
      currentLabels = List<String>.from(locData['yearLabels']);
    } else if (_selectedPeriod == '2 Tahun') {
      currentChartData = List<double>.from(locData['twoYearData']);
      currentValues = List<String>.from(locData['twoYearValues']);
      currentDates = List<String>.from(locData['twoYearDates']);
      currentLabels = List<String>.from(locData['twoYearLabels']);
    } else {
      // 1 Bulan
      currentChartData = List<double>.from(locData['monthData']);
      currentValues = List<String>.from(locData['monthValues']);
      currentDates = List<String>.from(locData['monthDates']);
      currentLabels = List<String>.from(locData['monthLabels']);
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Kartu Utama: Chart Per Lokasi dengan Dropdown & Tombol Periode
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
              // 1. Dropdown Pilih Lokasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLocation,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF114177)),
                          items: _locationOptions.map((loc) {
                            return DropdownMenuItem(
                              value: loc,
                              child: Row(
                                children: [
                                  const Icon(Icons.place, size: 16, color: Color(0xFF114177)),
                                  const SizedBox(width: 6),
                                  Text(
                                    loc,
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                                    overflow: TextOverflow.ellipsis,
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
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Tombol Pilihan Periode (1 Bulan, 1 Tahun, 2 Tahun)
              Row(
                children: ['1 Bulan', '1 Tahun', '2 Tahun'].map((p) {
                  final isSelected = _selectedPeriod == p;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
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
                              fontSize: 11,
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

              // Nilai Nominal Besar Dinamis
              Text(
                _inspectedLocationIndex != null && _inspectedLocationIndex! < currentValues.length
                    ? currentValues[_inspectedLocationIndex!]
                    : locData['totalOmzet'],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF114177),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _inspectedLocationIndex != null && _inspectedLocationIndex! < currentDates.length
                    ? 'Titik Waktu: ${currentDates[_inspectedLocationIndex!]} (Sentuh titik lain pada grafik)'
                    : 'Total Periode $_selectedPeriod • Kontribusi: ${locData['contribution']} dari total',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
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
                        onTapDown: (details) => _onLocationChartTouch(details.localPosition.dx, canvasWidth, currentChartData.length),
                        onPanStart: (details) => _onLocationChartTouch(details.localPosition.dx, canvasWidth, currentChartData.length),
                        onPanUpdate: (details) => _onLocationChartTouch(details.localPosition.dx, canvasWidth, currentChartData.length),
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
      ],
    );
  }

  // ==================== TAB 3: JENIS (PENDAPATAN TIPE KENDARAAN) ====================
  Widget _buildVehicleTypeTab() {
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
        const SizedBox(height: 14),

        // Proporsi Visual Mobil vs Motor (Hanya Mobil dan Motor Saja)
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rasio Kontribusi Omzet', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  Text('Total Rp 312.450.000', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 78,
                      child: Container(
                        height: 12,
                        color: const Color(0xFF114177),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      flex: 22,
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
                      Text('Mobil (78.5%)', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF114177))),
                    ],
                  ),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF17A18A), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('Motor (21.5%)', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF17A18A))),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── CUSTOM PAINTER: SMOOTH MOUNTAIN AREA CHART (TRADING STYLE) ───
class _MountainChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> pointValues;
  final List<String> pointDates;
  final List<String> xLabels;
  final int? inspectedIndex;
  final Color lineColor;
  final Color gradientStart;
  final Color gradientEnd;

  _MountainChartPainter({
    required this.data,
    required this.pointValues,
    required this.pointDates,
    required this.xLabels,
    this.inspectedIndex,
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

    // Path Curve & Gradient Fill
    final Path linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    final Path fillPath = Path.from(linePath);
    fillPath.lineTo(points.last.dx, baselineY);
    fillPath.lineTo(points.first.dx, baselineY);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientStart, gradientEnd],
      ).createShader(Rect.fromLTRB(0, topPadding, 0, baselineY));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // Draw Points & Labels
    final activeIndex = inspectedIndex ?? (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final bool isCurrent = i == activeIndex;

      if (isCurrent) {
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
      } else {
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
              color: isCurrent ? lineColor : const Color(0xFF76777B),
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
        oldDelegate.lineColor != lineColor;
  }
}