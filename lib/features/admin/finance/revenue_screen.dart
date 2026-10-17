import 'dart:math' as math;
import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  String _selectedMonth = 'Oktober 2026';
  final List<String> _months = ['Oktober 2026', 'September 2026', 'Agustus 2026'];

  int? _inspectedRevenueIndex;
  int? _inspectedExpenseIndex;

  // Mock data omzet bulanan, pengeluaran (termasuk inject saldo), dan laba bersih
  final Map<String, Map<String, dynamic>> _monthlyData = {
    'Oktober 2026': {
      'monthLabel': 'Oktober 2026',
      // 1. Total Omzet
      'omzetTotal': 'Rp 312.450.000',
      'omzetGrowth': '+15.7% vs bln lalu',
      'omzetTrx': '8.420 Transaksi Selesai',
      'omzetChartData': [0.35, 0.52, 0.48, 0.68, 0.74, 0.88, 0.96],
      'omzetValues': ['Rp 38.5 jt', 'Rp 42.1 jt', 'Rp 41.0 jt', 'Rp 49.8 jt', 'Rp 53.2 jt', 'Rp 61.5 jt', 'Rp 66.3 jt'],
      'omzetDates': ['1-4 Okt', '5-8 Okt', '9-12 Okt', '13-16 Okt', '17-20 Okt', '21-24 Okt', '25-31 Okt'],
      'omzetLabels': ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],

      // 2. Pengeluaran (Beban & Inject Saldo)
      'expenseTotal': 'Rp 48.200.000',
      'expenseGrowth': '-4.2% (Terkendali)',
      'expenseBreakdown': [
        {'name': 'Injeksi Saldo Dompet', 'amount': 'Rp 28.500.000', 'color': Color(0xFFE07A5F)},
        {'name': 'Kompensasi & Promo', 'amount': 'Rp 12.000.000', 'color': Color(0xFFD97706)},
        {'name': 'Biaya Payment Gateway', 'amount': 'Rp 7.700.000', 'color': Color(0xFF76777B)},
      ],
      'expenseChartData': [0.55, 0.42, 0.60, 0.38, 0.45, 0.50, 0.35],
      'expenseValues': ['Rp 8.2 jt', 'Rp 6.1 jt', 'Rp 9.0 jt', 'Rp 5.5 jt', 'Rp 6.8 jt', 'Rp 7.4 jt', 'Rp 5.2 jt'],
      'expenseDates': ['1-4 Okt', '5-8 Okt', '9-12 Okt', '13-16 Okt', '17-20 Okt', '21-24 Okt', '25-31 Okt'],
      'expenseLabels': ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],

      // 3. Laba Bersih
      'netProfitTotal': 'Rp 264.250.000',
      'netMargin': '84.6%',
      'profitGrowth': '+19.8% vs bln lalu',
    },
    'September 2026': {
      'monthLabel': 'September 2026',
      'omzetTotal': 'Rp 269.800.000',
      'omzetGrowth': '+12.1% vs bln lalu',
      'omzetTrx': '7.210 Transaksi Selesai',
      'omzetChartData': [0.30, 0.42, 0.45, 0.58, 0.65, 0.78, 0.85],
      'omzetValues': ['Rp 32.0 jt', 'Rp 36.5 jt', 'Rp 38.0 jt', 'Rp 43.2 jt', 'Rp 47.1 jt', 'Rp 54.0 jt', 'Rp 59.0 jt'],
      'omzetDates': ['1-4 Sep', '5-8 Sep', '9-12 Sep', '13-16 Sep', '17-20 Sep', '21-24 Sep', '25-30 Sep'],
      'omzetLabels': ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],

      'expenseTotal': 'Rp 50.300.000',
      'expenseGrowth': '+2.5% vs bln lalu',
      'expenseBreakdown': [
        {'name': 'Injeksi Saldo Dompet', 'amount': 'Rp 31.000.000', 'color': Color(0xFFE07A5F)},
        {'name': 'Kompensasi & Promo', 'amount': 'Rp 11.500.000', 'color': Color(0xFFD97706)},
        {'name': 'Biaya Payment Gateway', 'amount': 'Rp 7.800.000', 'color': Color(0xFF76777B)},
      ],
      'expenseChartData': [0.60, 0.48, 0.55, 0.42, 0.52, 0.48, 0.40],
      'expenseValues': ['Rp 9.1 jt', 'Rp 7.2 jt', 'Rp 8.3 jt', 'Rp 6.4 jt', 'Rp 7.8 jt', 'Rp 7.1 jt', 'Rp 6.0 jt'],
      'expenseDates': ['1-4 Sep', '5-8 Sep', '9-12 Sep', '13-16 Sep', '17-20 Sep', '21-24 Sep', '25-30 Sep'],
      'expenseLabels': ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],

      'netProfitTotal': 'Rp 219.500.000',
      'netMargin': '81.4%',
      'profitGrowth': '+14.6% vs bln lalu',
    },
    'Agustus 2026': {
      'monthLabel': 'Agustus 2026',
      'omzetTotal': 'Rp 240.500.000',
      'omzetGrowth': '+9.4% vs bln lalu',
      'omzetTrx': '6.650 Transaksi Selesai',
      'omzetChartData': [0.28, 0.35, 0.40, 0.52, 0.60, 0.70, 0.78],
      'omzetValues': ['Rp 28.5 jt', 'Rp 32.0 jt', 'Rp 35.1 jt', 'Rp 39.8 jt', 'Rp 43.5 jt', 'Rp 48.6 jt', 'Rp 53.0 jt'],
      'omzetDates': ['1-4 Agu', '5-8 Agu', '9-12 Agu', '13-16 Agu', '17-20 Agu', '21-24 Agu', '25-31 Agu'],
      'omzetLabels': ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],

      'expenseTotal': 'Rp 49.100.000',
      'expenseGrowth': '-1.8% vs bln lalu',
      'expenseBreakdown': [
        {'name': 'Injeksi Saldo Dompet', 'amount': 'Rp 29.800.000', 'color': Color(0xFFE07A5F)},
        {'name': 'Kompensasi & Promo', 'amount': 'Rp 12.100.000', 'color': Color(0xFFD97706)},
        {'name': 'Biaya Payment Gateway', 'amount': 'Rp 7.200.000', 'color': Color(0xFF76777B)},
      ],
      'expenseChartData': [0.50, 0.45, 0.58, 0.40, 0.48, 0.52, 0.44],
      'expenseValues': ['Rp 7.9 jt', 'Rp 7.1 jt', 'Rp 9.1 jt', 'Rp 6.3 jt', 'Rp 7.5 jt', 'Rp 8.2 jt', 'Rp 7.0 jt'],
      'expenseDates': ['1-4 Agu', '5-8 Agu', '9-12 Agu', '13-16 Agu', '17-20 Agu', '21-24 Agu', '25-31 Agu'],
      'expenseLabels': ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],

      'netProfitTotal': 'Rp 191.400.000',
      'netMargin': '79.6%',
      'profitGrowth': '+12.7% vs bln lalu',
    },
  };

  void _onOmzetChartTouch(double localX, double canvasWidth, int pointCount) {
    const double marginHorizontal = 24.0;
    final double chartWidth = canvasWidth - (marginHorizontal * 2);
    final double stepX = chartWidth / (pointCount - 1);
    final double relativeX = localX - marginHorizontal;
    int index = (relativeX / stepX).round();
    if (index < 0) index = 0;
    if (index >= pointCount) index = pointCount - 1;
    setState(() => _inspectedRevenueIndex = index);
  }

  void _onExpenseChartTouch(double localX, double canvasWidth, int pointCount) {
    const double marginHorizontal = 24.0;
    final double chartWidth = canvasWidth - (marginHorizontal * 2);
    final double stepX = chartWidth / (pointCount - 1);
    final double relativeX = localX - marginHorizontal;
    int index = (relativeX / stepX).round();
    if (index < 0) index = 0;
    if (index >= pointCount) index = pointCount - 1;
    setState(() => _inspectedExpenseIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final data = _monthlyData[_selectedMonth] ?? _monthlyData['Oktober 2026']!;
    final List<double> omzetChartData = List<double>.from(data['omzetChartData']);
    final List<String> omzetValues = List<String>.from(data['omzetValues']);
    final List<String> omzetDates = List<String>.from(data['omzetDates']);
    final List<String> omzetLabels = List<String>.from(data['omzetLabels']);

    final List<double> expenseChartData = List<double>.from(data['expenseChartData']);
    final List<String> expenseValues = List<String>.from(data['expenseValues']);
    final List<String> expenseDates = List<String>.from(data['expenseDates']);
    final List<String> expenseLabels = List<String>.from(data['expenseLabels']);
    final List<Map<String, dynamic>> expenseBreakdown = List<Map<String, dynamic>>.from(data['expenseBreakdown']);

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
              Text('Laporan Omzet & Keuangan', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              Text('Omzet Bulanan • Pengeluaran • Laba Bersih', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
            ],
          ),
          actions: [
            // Dropdown Pilihan Bulan
            Container(
              margin: const EdgeInsets.only(right: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMonth,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF114177)),
                  borderRadius: BorderRadius.circular(12),
                  items: _months.map((m) {
                    return DropdownMenuItem<String>(
                      value: m,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedMonth == m ? const Color(0xFF114177).withValues(alpha: 0.08) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          m,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: _selectedMonth == m ? FontWeight.bold : FontWeight.w500,
                            color: const Color(0xFF114177),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _selectedMonth = v;
                        _inspectedRevenueIndex = null;
                        _inspectedExpenseIndex = null;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            // ==========================================
            // 1. TOTAL OMZET BULANAN & CHART GUNUNG
            // ==========================================
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
                  // Header Card Omzet
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            child: const Icon(Icons.monetization_on_rounded, size: 22, color: Color(0xFF114177)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL OMZET BULANAN',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF76777B),
                                  letterSpacing: 0.6,
                                ),
                              ),
                              Text(
                                data['monthLabel'],
                                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF17A18A).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data['omzetGrowth'],
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Nilai Nominal Besar
                  Text(
                    _inspectedRevenueIndex != null && _inspectedRevenueIndex! < omzetValues.length
                        ? omzetValues[_inspectedRevenueIndex!]
                        : data['omzetTotal'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF114177),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _inspectedRevenueIndex != null && _inspectedRevenueIndex! < omzetDates.length
                        ? 'Periode: ${omzetDates[_inspectedRevenueIndex!]} (Sentuh grafik untuk titik lain)'
                        : '${data['omzetTrx']} • Rata-rata stabil',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
                  ),
                  const SizedBox(height: 16),

                  // ⛰️ Smooth Mountain Chart Omzet (Trading Style)
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
                            onTapDown: (details) => _onOmzetChartTouch(details.localPosition.dx, canvasWidth, omzetChartData.length),
                            onPanStart: (details) => _onOmzetChartTouch(details.localPosition.dx, canvasWidth, omzetChartData.length),
                            onPanUpdate: (details) => _onOmzetChartTouch(details.localPosition.dx, canvasWidth, omzetChartData.length),
                            child: SizedBox(
                              width: canvasWidth,
                              height: canvasHeight,
                              child: CustomPaint(
                                painter: _MountainChartPainter(
                                  data: omzetChartData,
                                  pointValues: omzetValues,
                                  pointDates: omzetDates,
                                  xLabels: omzetLabels,
                                  inspectedIndex: _inspectedRevenueIndex,
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

            // ==========================================
            // 2. TOTAL PENGELUARAN (INJECT SALDO) & CHART
            // ==========================================
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
                  // Header Card Pengeluaran
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE07A5F).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.outbox_rounded, size: 22, color: Color(0xFFE07A5F)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL PENGELUARAN & INJEK SALDO',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF76777B),
                                  letterSpacing: 0.6,
                                ),
                              ),
                              Text(
                                'Beban Injeksi Saldo & Operasional',
                                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE07A5F).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data['expenseGrowth'],
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFE07A5F)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Nilai Nominal Pengeluaran
                  Text(
                    _inspectedExpenseIndex != null && _inspectedExpenseIndex! < expenseValues.length
                        ? expenseValues[_inspectedExpenseIndex!]
                        : data['expenseTotal'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE07A5F),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _inspectedExpenseIndex != null && _inspectedExpenseIndex! < expenseDates.length
                        ? 'Periode: ${expenseDates[_inspectedExpenseIndex!]} (Sentuh grafik untuk titik lain)'
                        : 'Termasuk injeksi saldo dompet pengguna dan biaya merchant',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
                  ),
                  const SizedBox(height: 12),

                  // Rincian Pengeluaran Singkat
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: expenseBreakdown.map((b) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: b['color'], shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('${b['name']}: ', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                            Text(b['amount'], style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // ⛰️ Smooth Mountain Chart Pengeluaran (Trading Style)
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
                            onTapDown: (details) => _onExpenseChartTouch(details.localPosition.dx, canvasWidth, expenseChartData.length),
                            onPanStart: (details) => _onExpenseChartTouch(details.localPosition.dx, canvasWidth, expenseChartData.length),
                            onPanUpdate: (details) => _onExpenseChartTouch(details.localPosition.dx, canvasWidth, expenseChartData.length),
                            child: SizedBox(
                              width: canvasWidth,
                              height: canvasHeight,
                              child: CustomPaint(
                                painter: _MountainChartPainter(
                                  data: expenseChartData,
                                  pointValues: expenseValues,
                                  pointDates: expenseDates,
                                  xLabels: expenseLabels,
                                  inspectedIndex: _inspectedExpenseIndex,
                                  lineColor: const Color(0xFFE07A5F),
                                  gradientStart: const Color(0xFFE07A5F).withValues(alpha: 0.35),
                                  gradientEnd: const Color(0xFFE07A5F).withValues(alpha: 0.0),
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

            // ==========================================
            // 3. LABA BERSIH (NET PROFIT)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF114177), Color(0xFF0C2B50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF114177).withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.savings_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'LABA BERSIH (NET PROFIT)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(alpha: 0.85),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF17A18A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Margin ${data['netMargin']}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    data['netProfitTotal'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF17A18A), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${data['profitGrowth']} • Arus Kas Bersih Sehat',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Rumus Kalkulasi Bersih
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Omzet Masuk:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                            Text(data['omzetTotal'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Beban & Injeksi Saldo:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFFFFB4A2))),
                            Text('- ${data['expenseTotal']}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFFFB4A2))),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Hasil Laba Bersih Kas:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text(data['netProfitTotal'], style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF48CAE4))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── CUSTOM PAINTER: SMOOTH MOUNTAIN AREA CHART (TRADING STYLE SEPERTI DI SUPER ADMIN) ───
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
      ..strokeWidth = 1.0;

    for (final double ratio in [0.25, 0.50, 0.75]) {
      final double yGrid = topPadding + ratio * availableHeight;
      _drawDashedLine(
        canvas,
        Offset(marginHorizontal - 15, yGrid),
        Offset(size.width - marginHorizontal + 15, yGrid),
        gridPaint,
        dashWidth: 4,
        dashSpace: 4,
      );
    }

    // Baseline Axis
    final baselinePaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(marginHorizontal - 15, baselineY),
      Offset(size.width - marginHorizontal + 15, baselineY),
      baselinePaint,
    );

    // Area Gunung Spline
    final path = Path();
    path.moveTo(points.first.dx, baselineY);
    path.lineTo(points.first.dx, points.first.dy);

    const double tension = 0.22;
    for (int i = 0; i < points.length - 1; i++) {
      final Offset p0 = i > 0 ? points[i - 1] : points[0];
      final Offset p1 = points[i];
      final Offset p2 = points[i + 1];
      final Offset p3 = i < points.length - 2 ? points[i + 2] : p2;

      final Offset cp1 = Offset(p1.dx + (p2.dx - p0.dx) * tension, p1.dy + (p2.dy - p0.dy) * tension);
      final Offset cp2 = Offset(p2.dx - (p3.dx - p1.dx) * tension, p2.dy - (p3.dy - p1.dy) * tension);

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    path.lineTo(points.last.dx, baselineY);
    path.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientStart, gradientEnd],
      ).createShader(Rect.fromLTWH(0, topPadding, size.width, availableHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    // Garis Kurva Utama
    final strokePath = Path();
    strokePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final Offset p0 = i > 0 ? points[i - 1] : points[0];
      final Offset p1 = points[i];
      final Offset p2 = points[i + 1];
      final Offset p3 = i < points.length - 2 ? points[i + 2] : p2;

      final Offset cp1 = Offset(p1.dx + (p2.dx - p0.dx) * tension, p1.dy + (p2.dy - p0.dy) * tension);
      final Offset cp2 = Offset(p2.dx - (p3.dx - p1.dx) * tension, p2.dy - (p3.dy - p1.dy) * tension);

      strokePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(strokePath, linePaint);

    // Sumbu X Label Periode
    for (int i = 0; i < xLabels.length && i < points.length; i++) {
      final bool isSelected = inspectedIndex == i;

      final labelSpan = TextSpan(
        text: xLabels[i],
        style: TextStyle(
          fontSize: isSelected ? 10 : 9.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected ? lineColor : const Color(0xFF76777B),
        ),
      );
      final labelTp = TextPainter(
        text: labelSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final double labelX = points[i].dx - (labelTp.width / 2);
      final double labelY = baselineY + 8.0;

      if (isSelected) {
        final pillRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(labelX - 4, labelY - 2, labelTp.width + 8, labelTp.height + 4),
          const Radius.circular(4),
        );
        canvas.drawRRect(pillRect, Paint()..color = lineColor.withValues(alpha: 0.15));
      }

      labelTp.paint(canvas, Offset(labelX, labelY));
    }

    // Kursor Inspeksi Crosshair
    if (inspectedIndex != null && inspectedIndex! >= 0 && inspectedIndex! < points.length) {
      final Offset inspectPt = points[inspectedIndex!];

      // Garis vertikal crosshair
      final crosshairVerticalPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.7)
        ..strokeWidth = 1.2;
      _drawDashedLine(
        canvas,
        Offset(inspectPt.dx, topPadding - 10),
        Offset(inspectPt.dx, baselineY),
        crosshairVerticalPaint,
        dashWidth: 3,
        dashSpace: 3,
      );

      // Titik fokus dengan halo
      canvas.drawCircle(
        inspectPt,
        9,
        Paint()..color = lineColor.withValues(alpha: 0.25),
      );
      canvas.drawCircle(
        inspectPt,
        5,
        Paint()..color = lineColor,
      );
      canvas.drawCircle(
        inspectPt,
        2.5,
        Paint()..color = Colors.white,
      );

      // Tooltip Box Mengambang
      if (inspectedIndex! < pointDates.length && inspectedIndex! < pointValues.length) {
        final tooltipSpan = TextSpan(
          children: [
            TextSpan(
              text: '${pointDates[inspectedIndex!]} • ',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFFD1D5DB)),
            ),
            TextSpan(
              text: pointValues[inspectedIndex!],
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ],
        );
        final tp = TextPainter(
          text: tooltipSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        final double boxWidth = tp.width + 16.0;
        const double boxHeight = 24.0;
        double boxX = inspectPt.dx - (boxWidth / 2);
        double boxY = inspectPt.dy - boxHeight - 12.0;

        if (boxX < marginHorizontal) boxX = marginHorizontal;
        if (boxX + boxWidth > size.width - marginHorizontal) {
          boxX = size.width - marginHorizontal - boxWidth;
        }
        if (boxY < 2) boxY = inspectPt.dy + 12.0;

        final boxRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(boxX, boxY, boxWidth, boxHeight),
          const Radius.circular(6),
        );

        canvas.drawRRect(boxRect, Paint()..color = const Color(0xFF1E293B));
        tp.paint(canvas, Offset(boxX + 8.0, boxY + 5.0));
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