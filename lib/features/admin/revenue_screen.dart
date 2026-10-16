import '../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Time range selection
  String _selectedRange = 'Bulan Ini';
  final List<String> _ranges = ['Hari Ini', 'Minggu Ini', 'Bulan Ini', 'Bulan Lalu', '6 Bulan', 'Tahun Ini', 'Custom'];

  // Mock data for revenue analytics
  final Map<String, dynamic> _revenueData = {
    'today': {'revenue': 12500000, 'transactions': 342, 'avgTicket': 36550, 'growth': 12.5},
    'week': {'revenue': 78500000, 'transactions': 2156, 'avgTicket': 36410, 'growth': 8.3},
    'month': {'revenue': 312000000, 'transactions': 8420, 'avgTicket': 37055, 'growth': 15.7},
    'lastMonth': {'revenue': 269000000, 'transactions': 7210, 'avgTicket': 37310, 'growth': 12.1},
    'last6Months': {'revenue': 1680000000, 'transactions': 42500, 'avgTicket': 39529, 'growth': 18.2},
    'year': {'revenue': 3240000000, 'transactions': 81200, 'avgTicket': 39901, 'growth': 22.4},
  };

  // Daily revenue for charts (last 30 days)
  final List<Map<String, dynamic>> _dailyRevenue = List.generate(30, (i) {
    final date = DateTime.now().subtract(Duration(days: 29 - i));
    final base = 8000000 + (i * 50000) + (i % 7 * 2000000) - (i % 3 * 1000000);
    return {
      'date': date,
      'revenue': base.clamp(5000000, 25000000).toDouble(),
      'transactions': (base / 37000).round(),
      'occupancy': (65 + (i % 10) + (i % 5 * 2)).clamp(40, 95).toDouble(),
    };
  });

  // Revenue by location
  final List<Map<String, dynamic>> _locationRevenue = [
    {'name': 'Grand Indonesia', 'city': 'Jakarta Pusat', 'revenue': 850000000, 'transactions': 21200, 'occupancy': 88, 'slots': 450, 'growth': 22.5},
    {'name': 'Central Park Mall', 'city': 'Jakarta Barat', 'revenue': 620000000, 'transactions': 15800, 'occupancy': 82, 'slots': 300, 'growth': 18.3},
    {'name': 'Malioboro Mall', 'city': 'Yogyakarta', 'revenue': 380000000, 'transactions': 10500, 'occupancy': 75, 'slots': 200, 'growth': 15.7},
    {'name': 'Plaza Senayan', 'city': 'Jakarta Selatan', 'revenue': 340000000, 'transactions': 8900, 'occupancy': 78, 'slots': 250, 'growth': 12.4},
    {'name': 'Bandung Indah Plaza', 'city': 'Bandung', 'revenue': 280000000, 'transactions': 7200, 'occupancy': 72, 'slots': 180, 'growth': 10.2},
    {'name': 'Tunjungan Plaza', 'city': 'Surabaya', 'revenue': 250000000, 'transactions': 6800, 'occupancy': 68, 'slots': 220, 'growth': 8.9},
    {'name': 'Ciputra World', 'city': 'Surabaya', 'revenue': 220000000, 'transactions': 5900, 'occupancy': 65, 'slots': 200, 'growth': 7.5},
    {'name': 'Paris Van Java', 'city': 'Bandung', 'revenue': 195000000, 'transactions': 5200, 'occupancy': 62, 'slots': 160, 'growth': 5.8},
  ];

  // Revenue by vehicle type
  final List<Map<String, dynamic>> _vehicleTypeRevenue = [
    {'type': 'Mobil', 'revenue': 1850000000, 'percentage': 57.1, 'transactions': 46300, 'avgTicket': 39957, 'color': Color(0xFF45474A)},
    {'type': 'Motor', 'revenue': 680000000, 'percentage': 21.0, 'transactions': 22400, 'avgTicket': 30357, 'color': Color(0xFF114177)},
    {'type': 'EV', 'revenue': 420000000, 'percentage': 13.0, 'transactions': 8100, 'avgTicket': 51852, 'color': Color(0xFFE07A5F)},
    {'type': 'Disabilitas', 'revenue': 290000000, 'percentage': 8.9, 'transactions': 4400, 'avgTicket': 65909, 'color': Color(0xFF9B59B6)},
  ];

  // Revenue by zone
  final List<Map<String, dynamic>> _zoneRevenue = [
    {'zone': 'Jakarta Pusat', 'revenue': 1200000000, 'locations': 3, 'occupancy': 85, 'growth': 20.1},
    {'zone': 'Jakarta Barat', 'revenue': 620000000, 'locations': 1, 'occupancy': 82, 'growth': 18.3},
    {'zone': 'Jakarta Selatan', 'revenue': 340000000, 'locations': 1, 'occupancy': 78, 'growth': 12.4},
    {'zone': 'Yogyakarta', 'revenue': 380000000, 'locations': 1, 'occupancy': 75, 'growth': 15.7},
    {'zone': 'Bandung', 'revenue': 475000000, 'locations': 2, 'occupancy': 67, 'growth': 8.2},
    {'zone': 'Surabaya', 'revenue': 470000000, 'locations': 2, 'occupancy': 66, 'growth': 8.2},
  ];

  // Monthly trend for forecast
  final List<Map<String, dynamic>> _monthlyTrend = [
    {'month': 'Jul', 'revenue': 245000000, 'transactions': 6200},
    {'month': 'Agu', 'revenue': 258000000, 'transactions': 6500},
    {'month': 'Sep', 'revenue': 272000000, 'transactions': 6800},
    {'month': 'Okt', 'revenue': 285000000, 'transactions': 7100},
    {'month': 'Nov', 'revenue': 298000000, 'transactions': 7400},
    {'month': 'Des', 'revenue': 312000000, 'transactions': 8420},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentData => _revenueData[_selectedRange.toLowerCase().replaceAll(' ', '')] ?? _revenueData['month']!;

  @override
  Widget build(BuildContext context) {
    final data = _currentData;

    return Theme(
      data: AppTheme.light,
      child: Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18))),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analytics Pendapatan', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('MRR • Occupancy • Forecast', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedRange,
            onSelected: (v) => setState(() => _selectedRange = v),
            itemBuilder: (_) => _ranges.map((r) => PopupMenuItem(value: r, child: Text(r))).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF114177)),
                const SizedBox(width: 6),
                Text(_selectedRange, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF114177)),
              ]),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF114177),
          unselectedLabelColor: const Color(0xFF76777B),
          indicatorColor: const Color(0xFF114177),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Trend Harian'),
            Tab(text: 'Per Lokasi'),
            Tab(text: 'Per Tipe/Jenis'),
            Tab(text: 'Forecast'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(data),
          _buildDailyTrendTab(),
          _buildLocationTab(),
          _buildVehicleTypeTab(),
          _buildForecastTab(),
        ],
      ),
    ));
  }

  // ============ TAB 1: RINGKASAN ============
  Widget _buildSummaryTab(Map<String, dynamic> data) {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Cards
            _buildSectionTitle('KPI Utama', subtitle: 'Periode: $_selectedRange'),
            _buildCard(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 600;
                  if (isNarrow) {
                    return Column(
                      children: [
                        _buildKPICard('Total Pendapatan', 'Rp ${_formatNumber(data['revenue'])}', Icons.attach_money, const Color(0xFF114177), growth: data['growth'], growthLabel: 'vs periode sebelumnya'),
                        const SizedBox(height: 12),
                        _buildKPICard('Transaksi', _formatNumber(data['transactions']), Icons.receipt_long, const Color(0xFF17A18A), growth: 5.2, growthLabel: 'vs periode sebelumnya'),
                        const SizedBox(height: 12),
                        _buildKPICard('Rata-rata/Tiket', 'Rp ${_formatNumber(data['avgTicket'])}', Icons.analytics, const Color(0xFFE07A5F), growth: -2.1, growthLabel: 'vs periode sebelumnya'),
                        const SizedBox(height: 12),
                        _buildKPICard('Rata-rata/Hari', 'Rp ${_formatNumber((data['revenue'] / (_selectedRange.contains('Bulan') ? 30 : _selectedRange.contains('Minggu') ? 7 : 1)).round())}', Icons.calendar_today, const Color(0xFF9B59B6)),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      _buildKPICard('Total Pendapatan', 'Rp ${_formatNumber(data['revenue'])}', Icons.attach_money, const Color(0xFF114177), growth: data['growth'], growthLabel: 'vs periode sebelumnya'),
                      const SizedBox(width: 12),
                      _buildKPICard('Transaksi', _formatNumber(data['transactions']), Icons.receipt_long, const Color(0xFF17A18A), growth: 5.2, growthLabel: 'vs periode sebelumnya'),
                      const SizedBox(width: 12),
                      _buildKPICard('Rata-rata/Tiket', 'Rp ${_formatNumber(data['avgTicket'])}', Icons.analytics, const Color(0xFFE07A5F), growth: -2.1, growthLabel: 'vs periode sebelumnya'),
                      const SizedBox(width: 12),
                      _buildKPICard('Rata-rata/Hari', 'Rp ${_formatNumber((data['revenue'] / (_selectedRange.contains('Bulan') ? 30 : _selectedRange.contains('Minggu') ? 7 : 1)).round())}', Icons.calendar_today, const Color(0xFF9B59B6)),
                    ],
                  );
                },
              ),
            ),

          // MRR Card
          _buildSectionTitle('Monthly Recurring Revenue (MRR)'),
          _buildCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('MRR Saat Ini', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
                      Text('Rp ${_formatNumber(312000000)}', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    ]),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF17A18A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        const Icon(Icons.trending_up, size: 16, color: Color(0xFF17A18A)),
                        const SizedBox(width: 4),
                        Text('+15.7% MoM', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 120,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: const Color(0xFFE4DFD5), strokeWidth: 1)),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50, getTitlesWidget: (v, _) => Text('${(v/1e6).toInt()}M', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF76777B))))),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                          final months = ['Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
                          if (v.toInt() >= 0 && v.toInt() < months.length) return Text(months[v.toInt()], style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF76777B)));
                          return const Text('');
                        })),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _monthlyTrend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['revenue'] / 1e6)).toList(),
                          isCurved: true,
                          color: const Color(0xFF114177),
                          barWidth: 3,
                          dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: const Color(0xFF114177), strokeWidth: 2, strokeColor: Colors.white)),
                          belowBarData: BarAreaData(show: true, color: const Color(0xFF114177).withValues(alpha: 0.1)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Occupancy Overview
          _buildSectionTitle('Ringkasan Occupancy'),
          _buildCard(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                if (isNarrow) {
                  return Column(
                    children: [
                      _buildOccupancyCard('Rata-rata Keseluruhan', '78%', const Color(0xFF17A18A), Icons.park),
                      const SizedBox(height: 12),
                      _buildOccupancyCard('Peak Hour (18-20)', '92%', const Color(0xFFE07A5F), Icons.schedule),
                      const SizedBox(height: 12),
                      _buildOccupancyCard('Off Peak (02-05)', '23%', const Color(0xFF76777B), Icons.nightlight),
                      const SizedBox(height: 12),
                      _buildOccupancyCard('Weekend vs Weekday', '+15%', const Color(0xFF9B59B6), Icons.weekend),
                    ],
                  );
                }
                return Row(
                  children: [
                    _buildOccupancyCard('Rata-rata Keseluruhan', '78%', const Color(0xFF17A18A), Icons.park),
                    const SizedBox(width: 12),
                    _buildOccupancyCard('Peak Hour (18-20)', '92%', const Color(0xFFE07A5F), Icons.schedule),
                    const SizedBox(width: 12),
                    _buildOccupancyCard('Off Peak (02-05)', '23%', const Color(0xFF76777B), Icons.nightlight),
                    const SizedBox(width: 12),
                    _buildOccupancyCard('Weekend vs Weekday', '+15%', const Color(0xFF9B59B6), Icons.weekend),
                  ],
                );
              },
            ),
          ),

          // Quick Stats
          _buildSectionTitle('Statistik Cepat'),
          _buildCard(
            child: Column(
              children: [
                _buildQuickStatRow('Total Slot Tersedia', '1.960', Icons.grid_3x3, const Color(0xFF45474A)),
                _buildQuickStatRow('Rata-rata Durasi Parkir', '2j 45m', Icons.timer, const Color(0xFF114177)),
                _buildQuickStatRow('Konversi Booking → Check-in', '94.2%', Icons.check_circle, const Color(0xFF17A18A)),
                _buildQuickStatRow('Refund Rate', '1.3%', Icons.money_off, const Color(0xFFD94B4B)),
                _buildQuickStatRow('Top Up Wallet / Bulan', 'Rp 1.2 M', Icons.account_balance_wallet, const Color(0xFFE07A5F)),
                _buildQuickStatRow('Active Subscribers', '1.240', Icons.subscriptions, const Color(0xFF9B59B6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ TAB 2: TREND HARIAN ============
  Widget _buildDailyTrendTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Trend Harian (30 Hari Terakhir)'),

          // Revenue Chart
          _buildCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pendapatan Harian', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: const Color(0xFFE4DFD5), strokeWidth: 1)),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 60, getTitlesWidget: (v, _) => Text('${(v/1e6).toStringAsFixed(1)}M', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF76777B))))),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 5, getTitlesWidget: (v, _) {
                          if (v.toInt() >= 0 && v.toInt() < _dailyRevenue.length) return Text(_formatDate(_dailyRevenue[v.toInt()]['date']), style: GoogleFonts.plusJakartaSans(fontSize: 8, color: const Color(0xFF76777B)));
                          return const Text('');
                        })),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _dailyRevenue.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['revenue'] / 1e6)).toList(),
                          isCurved: true,
                          color: const Color(0xFF114177),
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: const Color(0xFF114177).withValues(alpha: 0.1)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Transactions Chart
          _buildCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Volume Transaksi Harian', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text('${(v/1000).toInt()}k', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF76777B))))),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 5, getTitlesWidget: (v, _) {
                          if (v.toInt() >= 0 && v.toInt() < _dailyRevenue.length) return Text(_formatDate(_dailyRevenue[v.toInt()]['date']), style: GoogleFonts.plusJakartaSans(fontSize: 8, color: const Color(0xFF76777B)));
                          return const Text('');
                        })),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _dailyRevenue.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [
                        BarChartRodData(toY: e.value['transactions'].toDouble(), color: const Color(0xFF17A18A), width: 10, borderRadius: BorderRadius.circular(4)),
                      ])).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Occupancy Chart
          _buildCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Occupancy Rate Harian', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: const Color(0xFFE4DFD5), strokeWidth: 1)),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text('${v.toInt()}%', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF76777B))))),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 5, getTitlesWidget: (v, _) {
                          if (v.toInt() >= 0 && v.toInt() < _dailyRevenue.length) return Text(_formatDate(_dailyRevenue[v.toInt()]['date']), style: GoogleFonts.plusJakartaSans(fontSize: 8, color: const Color(0xFF76777B)));
                          return const Text('');
                        })),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _dailyRevenue.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['occupancy'])).toList(),
                          isCurved: true,
                          color: const Color(0xFFE07A5F),
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: const Color(0xFFE07A5F).withValues(alpha: 0.1)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ TAB 3: PER LOKASI ============
  Widget _buildLocationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Pendapatan per Lokasi'),
          _buildCard(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _locationRevenue.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE4DFD5)),
              itemBuilder: (_, i) {
                final loc = _locationRevenue[i];
                return _buildLocationRow(loc, i + 1);
              },
            ),
          ),

          _buildSectionTitle('Pendapatan per Zona/Kota'),
          _buildCard(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _zoneRevenue.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE4DFD5)),
              itemBuilder: (_, i) {
                final zone = _zoneRevenue[i];
                return _buildZoneRow(zone);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(Map<String, dynamic> loc, int rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: rank <= 3 ? const Color(0xFFE07A5F).withValues(alpha: 0.1) : const Color(0xFFE4DFD5), borderRadius: BorderRadius.circular(8)), child: Center(child: Text('$rank', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: rank <= 3 ? const Color(0xFFE07A5F) : const Color(0xFF76777B))))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(loc['name'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)), overflow: TextOverflow.ellipsis),
              Text(loc['city'], style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B)), overflow: TextOverflow.ellipsis),
            ]),
          ),
          Flexible(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Rp ${_formatNumber(loc['revenue'])}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF114177)), overflow: TextOverflow.ellipsis),
              Text('${loc['transactions']} txn', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B)), overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: _occupancyColor(loc['occupancy']).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text('${loc['occupancy']}%', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: _occupancyColor(loc['occupancy'])))),
              const SizedBox(height: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF17A18A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text('+${loc['growth']}%', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A)))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneRow(Map<String, dynamic> zone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF114177).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.location_city, color: Color(0xFF114177), size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(zone['zone'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              Text('${zone['locations']} lokasi', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B)), overflow: TextOverflow.ellipsis),
            ]),
          ),
          Flexible(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Rp ${_formatNumber(zone['revenue'])}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF114177)), overflow: TextOverflow.ellipsis),
              Text('Occupancy: ${zone['occupancy']}%', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B)), overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: zone['growth'] > 15 ? const Color(0xFF17A18A).withValues(alpha: 0.1) : const Color(0xFFE07A5F).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text('+${zone['growth']}%', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: zone['growth'] > 15 ? const Color(0xFF17A18A) : const Color(0xFFE07A5F))),
            ),
          ),
        ],
      ),
    );
  }

  // ============ TAB 4: PER TIPE KENDARAAN ============
  Widget _buildVehicleTypeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Pendapatan per Tipe Kendaraan'),
          _buildCard(
            child: Column(
              children: [
                // Pie Chart
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sections: _vehicleTypeRevenue.asMap().entries.map((e) {
                        final v = e.value;
                        return PieChartSectionData(
                          value: v['percentage'],
                          title: '${v['percentage']}%',
                          color: v['color'],
                          radius: 80,
                          titleStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          badgeWidget: Text(v['type'], style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: v['color'])),
                          badgePositionPercentageOffset: 1.3,
                        );
                      }).toList(),
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Details
                ..._vehicleTypeRevenue.map((v) => _buildVehicleTypeRow(v)).toList(),
              ],
            ),
          ),

          _buildSectionTitle('Perbandingan Tarif per Tipe'),
          _buildCard(
            child: Column(
              children: _vehicleTypeRevenue.map((v) => _buildRateComparisonRow(v)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTypeRow(Map<String, dynamic> v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: v['color'], shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(v['type'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          Flexible(child: Text('Rp ${_formatNumber(v['revenue'])}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF114177)), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 16),
          Flexible(child: Text('${v['transactions']} txn', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 12),
          Flexible(child: Text('Avg: Rp ${_formatNumber(v['avgTicket'])}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildRateComparisonRow(Map<String, dynamic> v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: v['color'], shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(v['type'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          Flexible(
            child: Container(
              height: 8,
              width: 120,
              child: Stack(
                children: [
                  Container(height: 8, decoration: BoxDecoration(color: const Color(0xFFE4DFD5), borderRadius: BorderRadius.circular(4))),
                  FractionallySizedBox(widthFactor: (v['avgTicket'] / 70000).clamp(0.0, 1.0), child: Container(height: 8, decoration: BoxDecoration(color: v['color'], borderRadius: BorderRadius.circular(4)))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(child: Text('Rp ${_formatNumber(v['avgTicket'])}/jam', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF114177)), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  // ============ TAB 5: FORECAST ============
  Widget _buildForecastTab() {
    final nextMonthForecast = _monthlyTrend.last['revenue'] * 1.15;
    final nextQuarterForecast = _monthlyTrend.last['revenue'] * 3 * 1.12;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Forecast & Proyeksi', subtitle: 'Berdasarkan trend 6 bulan terakhir (linear regression sederhana)'),

          // Forecast Cards
          _buildCard(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                if (isNarrow) {
                  return Column(
                    children: [
                      _buildForecastCard('Bulan Depan', 'Rp ${_formatNumber(nextMonthForecast.round())}', '+15%', const Color(0xFF114177), Icons.event),
                      const SizedBox(height: 12),
                      _buildForecastCard('Triwulan Depan', 'Rp ${_formatNumber(nextQuarterForecast.round())}', '+12%', const Color(0xFF17A18A), Icons.date_range),
                      const SizedBox(height: 12),
                      _buildForecastCard('Tahun Depan (Est.)', 'Rp ${_formatNumber((_revenueData['year']!['revenue'] * 1.22).round())}', '+22%', const Color(0xFF9B59B6), Icons.trending_up),
                    ],
                  );
                }
                return Row(
                  children: [
                    _buildForecastCard('Bulan Depan', 'Rp ${_formatNumber(nextMonthForecast.round())}', '+15%', const Color(0xFF114177), Icons.event),
                    const SizedBox(width: 12),
                    _buildForecastCard('Triwulan Depan', 'Rp ${_formatNumber(nextQuarterForecast.round())}', '+12%', const Color(0xFF17A18A), Icons.date_range),
                    const SizedBox(width: 12),
                    _buildForecastCard('Tahun Depan (Est.)', 'Rp ${_formatNumber((_revenueData['year']!['revenue'] * 1.22).round())}', '+22%', const Color(0xFF9B59B6), Icons.trending_up),
                  ],
                );
              },
            ),
          ),

          // Forecast Chart
          _buildCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Proyeksi Pendapatan Bulanan', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: const Color(0xFFE4DFD5), strokeWidth: 1)),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 60, getTitlesWidget: (v, _) => Text('${(v/1e6).toInt()}M', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF76777B))))),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                          final allMonths = ['Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des', 'Jan\'25', 'Feb\'25', 'Mar\'25'];
                          if (v.toInt() >= 0 && v.toInt() < allMonths.length) return Text(allMonths[v.toInt()], style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF76777B)));
                          return const Text('');
                        })),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        // Actual
                        LineChartBarData(
                          spots: _monthlyTrend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['revenue'] / 1e6)).toList(),
                          isCurved: true,
                          color: const Color(0xFF114177),
                          barWidth: 3,
                          dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: const Color(0xFF114177), strokeWidth: 2, strokeColor: Colors.white)),
                        ),
                        // Forecast
                        LineChartBarData(
                          spots: [
                            FlSpot(5, _monthlyTrend.last['revenue'] / 1e6),
                            FlSpot(6, nextMonthForecast / 1e6),
                            FlSpot(7, (nextMonthForecast * 1.05) / 1e6),
                            FlSpot(8, (nextMonthForecast * 1.10) / 1e6),
                          ],
                          isCurved: true,
                          color: const Color(0xFFE07A5F),
                          barWidth: 3,
                          dashArray: [8, 4],
                          dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: const Color(0xFFE07A5F), strokeWidth: 2, strokeColor: Colors.white)),
                          belowBarData: BarAreaData(show: true, color: const Color(0xFFE07A5F).withValues(alpha: 0.1)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildLegendDot('Aktual', const Color(0xFF114177)),
                    const SizedBox(width: 16),
                    _buildLegendDot('Forecast', const Color(0xFFE07A5F), dashed: true),
                  ],
                ),
              ],
            ),
          ),

          // Assumptions
          _buildSectionTitle('Asumsi Forecast'),
          _buildCard(
            child: Column(
              children: [
                _buildAssumptionRow('Pertumbuhan Organik', '15% YoY', 'Berdasarkan trend 6 bulan'),
                _buildAssumptionRow('Expansi Lokasi Baru', '+2 lokasi/Q1', 'Jakarta Timur & Bekasi'),
                _buildAssumptionRow('EV Adoption Rate', '+25% per kuartal', 'Insentif pemerintah'),
                _buildAssumptionRow('Weekend Premium', '+20% revenue', 'Dynamic pricing aktif'),
                _buildAssumptionRow('Churn Rate', '< 5% bulanan', 'Retensi langganan tinggi'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ HELPER WIDGETS ============
  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          if (subtitle != null) Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DFD5))),
      child: child,
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color, {double? growth, String? growthLabel}) {
    return Flexible(
      fit: FlexFit.tight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 140),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 8),
                  Flexible(child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(child: FittedBox(child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: color)))),
              if (growth != null) ...[
                const SizedBox(height: 4),
                Flexible(child: Row(children: [
                  Icon(growth >= 0 ? Icons.trending_up : Icons.trending_down, size: 12, color: growth >= 0 ? const Color(0xFF17A18A) : const Color(0xFFD94B4B)),
                  const SizedBox(width: 4),
                  Flexible(child: Text('${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: growth >= 0 ? const Color(0xFF17A18A) : const Color(0xFFD94B4B)), overflow: TextOverflow.ellipsis)),
                  if (growthLabel != null) ...[const SizedBox(width: 4), Flexible(child: Text(growthLabel, style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF76777B)), overflow: TextOverflow.ellipsis))],
                ])),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOccupancyCard(String label, String value, Color color, IconData icon) {
    return Flexible(
      fit: FlexFit.tight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 120),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 8),
              Flexible(child: FittedBox(child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: color)))),
              Flexible(child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, color: color), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: color)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF45474A)))),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        ],
      ),
    );
  }

  Widget _buildForecastCard(String label, String value, String growth, Color color, IconData icon) {
    return Flexible(
      fit: FlexFit.tight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 120),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 8),
              Flexible(child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
              const SizedBox(height: 4),
              Flexible(child: FittedBox(child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center))),
              const SizedBox(height: 4),
              Flexible(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF17A18A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text(growth, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color, {bool dashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
      ],
    );
  }

  Widget _buildAssumptionRow(String label, String value, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18)), overflow: TextOverflow.ellipsis)),
          Expanded(child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177)), overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(detail, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Color _occupancyColor(double occupancy) {
    if (occupancy >= 85) return const Color(0xFFD94B4B);
    if (occupancy >= 70) return const Color(0xFFE07A5F);
    return const Color(0xFF17A18A);
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}