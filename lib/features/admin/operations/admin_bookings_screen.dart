import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/ticket_status_helper.dart';
import 'backend/admin_bookings_backend.dart';
import 'backend/admin_operations_dashboard_backend.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedLocationFilter = 'Semua';
  String _selectedVehicleFilter = 'Semua';

  List<String> get _locationFilters {
    final list = AdminOperationsDashboardBackend.instance.locations
        .map((l) => (l['name'] as String?) ?? '')
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList();
    return ['Semua', ...list];
  }
  final List<String> _vehicleFilters = ['Semua', 'Mobil', 'Motor', 'EV'];

  List<Map<String, dynamic>> get _bookings => AdminBookingsBackend.instance.bookings;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    AdminBookingsBackend.instance.fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<Map<String, dynamic>>> get _groupedBookings {
    final groups = <String, List<Map<String, dynamic>>>{
      TicketMark.ready: [],
      TicketMark.aktif: [],
      TicketMark.selesai: [],
      TicketMark.belumDibayar: [],
      TicketMark.dibatalkan: [],
    };

    for (var b in _filteredBookings) {
      final status = b['status'];
      if (groups.containsKey(status)) {
        groups[status]!.add(b);
      }
    }
    return groups;
  }

  List<Map<String, dynamic>> get _filteredBookings {
    final q = _searchController.text.toLowerCase();
    return _bookings.where((b) {
      final matchesSearch = b['id'].toString().toLowerCase().contains(q) ||
          b['user']['name'].toString().toLowerCase().contains(q) ||
          b['user']['phone'].toString().toLowerCase().contains(q) ||
          b['location'].toString().toLowerCase().contains(q) ||
          b['vehicle']['plate'].toString().toLowerCase().contains(q);

      if (!matchesSearch) return false;

      final matchesLocation = _selectedLocationFilter == 'Semua' || b['location'] == _selectedLocationFilter;
      final matchesVehicle = _selectedVehicleFilter == 'Semua' || b['vehicle']['type'] == _selectedVehicleFilter;

      return matchesLocation && matchesVehicle;
    }).toList();
  }

  Color _getStatusColor(String status) {
    return TicketMark.getColor(status);
  }

  Color _getStatusBg(String status) {
    return TicketMark.getBgColor(status);
  }

  Color _getVehicleColor(String type) {
    switch (type) {
      case 'Mobil':
        return const Color(0xFF114177);
      case 'Motor':
        return const Color(0xFFE07A5F);
      case 'EV':
        return const Color(0xFF17A18A);
      default:
        return const Color(0xFF76777B);
    }
  }

  IconData _getVehicleIcon(String type) {
    switch (type) {
      case 'Mobil':
        return Icons.directions_car;
      case 'Motor':
        return Icons.two_wheeler;
      case 'EV':
        return Icons.ev_station;
      default:
        return Icons.directions_car;
    }
  }

  void _showBookingDetail(Map<String, dynamic> booking) {
    final statusColor = _getStatusColor(booking['status']);
    final statusBg = _getStatusBg(booking['status']);
    final vehicleColor = _getVehicleColor(booking['vehicle']['type']);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Detail Booking', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                        Text(booking['id'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(10)),
                      child: Text(booking['status'], style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 20),

                // User Info
                Row(
                  children: [
                    Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFE3EEFF), borderRadius: BorderRadius.circular(14)), child: Center(child: Text(booking['user']['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF114177))))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(booking['user']['name'], style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      Text(booking['user']['phone'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                    ])),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 20),

                // Booking Info
                _buildSectionTitle('Informasi Booking'),
                const SizedBox(height: 12),
                _buildInfoRow('Tipe Booking', booking['bookingType']),
                _buildInfoRow('Lokasi', '${booking['location']} (Lantai ${booking['floor']})'),
                _buildInfoRow('Slot', booking['slot']),
                _buildInfoRow('Kendaraan', '${booking['vehicle']['plate']} (${booking['vehicle']['type']})', valueWidget: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: vehicleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_getVehicleIcon(booking['vehicle']['type']), size: 12, color: vehicleColor), const SizedBox(width: 4), Text(booking['vehicle']['type'], style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: vehicleColor))]))),
                _buildInfoRow('Mulai', _formatDateTime(booking['startTime'])),
                _buildInfoRow('Selesai', _formatDateTime(booking['endTime'])),
                _buildInfoRow('Durasi', '${booking['durationHours']} jam'),
                _buildInfoRow('Dibuat Pada', _formatDateTime(booking['createdAt'])),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 20),

                // Payment
                _buildSectionTitle('Pembayaran'),
                const SizedBox(height: 12),
                _buildInfoRow('Total Harga', 'Rp ${_formatNumber(booking['totalPrice'])}'),
                _buildInfoRow('Status Bayar', booking['paymentStatus'], valueColor: booking['paymentStatus'] == 'Dibayar' ? const Color(0xFF17A18A) : const Color(0xFFE07A5F)),
                if (booking['status'] == 'Dibatalkan' && booking['cancelReason'] != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow('Alasan Batal', booking['cancelReason']),
                ],
                const SizedBox(height: 20),

                // Actions
                if (booking['status'] == TicketMark.ready || booking['status'] == TicketMark.aktif || booking['status'] == TicketMark.belumDibayar) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showCancelBookingDialog(booking);
                          },
                          icon: const Icon(Icons.cancel_outlined, size: 18, color: Color(0xFFD94B4B)),
                          label: Text('Batalkan Booking', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD94B4B)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                      if (booking['status'] == TicketMark.ready || booking['status'] == TicketMark.aktif) ...[
                        const SizedBox(width: 12),
                        if (booking['status'] == TicketMark.ready)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _confirmStartSession(booking);
                              },
                              icon: const Icon(Icons.play_arrow, size: 18, color: Colors.white),
                              label: Text('Mulai Sesi', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF17A18A), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                            ),
                          )
                        else
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _forceCheckout(booking);
                              },
                              icon: const Icon(Icons.exit_to_app, size: 18, color: Colors.white),
                              label: Text('Force Check-Out', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE07A5F), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                            ),
                          ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelBookingDialog(Map<String, dynamic> booking) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text('Batalkan Booking ${booking['id']}', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Booking untuk ${booking['user']['name']} di ${booking['location']} akan dibatalkan.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A))),
            const SizedBox(height: 16),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Alasan Pembatalan (wajib)', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B), fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () async {
              if (reasonCtrl.text.isNotEmpty) {
                final nav = Navigator.of(context);
                final sm = ScaffoldMessenger.of(context);
                await AdminBookingsBackend.instance.cancelBooking(booking['id'].toString(), reasonCtrl.text);
                if (!mounted) return;
                nav.pop();
                sm.showSnackBar(SnackBar(content: Text('Booking dibatalkan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFFD94B4B), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD94B4B), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Konfirmasi Batalkan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmStartSession(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text('Mulai Sesi Parkir?', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        content: Text('Ini akan mengubah status booking menjadi "Aktif" dan memulai timer parkir untuk ${booking['user']['name']}.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B), fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final idx = _bookings.indexWhere((b) => b['id'] == booking['id']);
                if (idx != -1) _bookings[idx]['status'] = 'Aktif';
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sesi dimulai', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF17A18A), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF17A18A), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Ya, Mulai Sesi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _forceCheckout(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text('Force Check-Out?', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        content: Text('Ini akan memaksa check-out dan mengakhiri sesi parkir untuk ${booking['user']['name']} di slot ${booking['slot']}.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B), fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final idx = _bookings.indexWhere((b) => b['id'] == booking['id']);
                if (idx != -1) _bookings[idx]['status'] = 'Selesai';
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Force check-out berhasil', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF17A18A), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF17A18A), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Ya, Force Check-Out', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)));
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, Widget? valueWidget}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
          valueWidget ?? Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor ?? const Color(0xFF1A1A18))),
        ],
      ),
    );
  }

  String _formatDateTime(String dt) {
    try {
      final d = DateTime.parse(dt);
      return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dt;
    }
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminBookingsBackend.instance,
      builder: (context, _) {
        final stats = {
          TicketMark.ready: _bookings.where((b) => b['status'] == TicketMark.ready).length,
          TicketMark.aktif: _bookings.where((b) => b['status'] == TicketMark.aktif).length,
          TicketMark.selesai: _bookings.where((b) => b['status'] == TicketMark.selesai).length,
          TicketMark.belumDibayar: _bookings.where((b) => b['status'] == TicketMark.belumDibayar).length,
          TicketMark.dibatalkan: _bookings.where((b) => b['status'] == TicketMark.dibatalkan).length,
        };

        return Theme(
          data: AppTheme.light,
          child: Scaffold(
            backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18)),
          ),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Manajemen Booking', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          Text('Reservasi & Sesi Parkir Pengguna', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE4DFD5)))),
            child: TabBar(
              controller: _tabController,
              labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
              labelColor: const Color(0xFF114177),
              unselectedLabelColor: const Color(0xFF76777B),
              indicatorColor: const Color(0xFF114177),
              indicatorWeight: 2,
              isScrollable: true,
              tabs: const [
                Tab(text: TicketMark.ready),
                Tab(text: TicketMark.aktif),
                Tab(text: TicketMark.selesai),
                Tab(text: TicketMark.belumDibayar),
                Tab(text: TicketMark.dibatalkan),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Stat overview
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildStatCard(TicketMark.ready, '${stats[TicketMark.ready]}', TicketMark.getColor(TicketMark.ready), TicketMark.getBgColor(TicketMark.ready)),
                    const SizedBox(width: 10),
                    _buildStatCard(TicketMark.aktif, '${stats[TicketMark.aktif]}', TicketMark.getColor(TicketMark.aktif), TicketMark.getBgColor(TicketMark.aktif)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatCard(TicketMark.selesai, '${stats[TicketMark.selesai]}', TicketMark.getColor(TicketMark.selesai), TicketMark.getBgColor(TicketMark.selesai)),
                    const SizedBox(width: 10),
                    _buildStatCard(TicketMark.belumDibayar, '${stats[TicketMark.belumDibayar]}', TicketMark.getColor(TicketMark.belumDibayar), TicketMark.getBgColor(TicketMark.belumDibayar)),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1A1A18)),
                          decoration: InputDecoration(
                            hintText: 'Cari ID, nama, lokasi, plat...',
                            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            filled: false,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filters
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _locationFilters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _locationFilters[i];
                final sel = _selectedLocationFilter == f;
                return GestureDetector(onTap: () => setState(() => _selectedLocationFilter = f), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: sel ? const Color(0xFF114177) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)), child: Center(child: Text(f, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.w500, color: sel ? Colors.white : const Color(0xFF45474A))))));
              },
            ),
          ),
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _vehicleFilters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _vehicleFilters[i];
                final sel = _selectedVehicleFilter == f;
                return GestureDetector(onTap: () => setState(() => _selectedVehicleFilter = f), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: sel ? const Color(0xFFE07A5F) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)), child: Center(child: Text(f, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.w500, color: sel ? Colors.white : const Color(0xFF45474A))))));
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4DFD5)),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(_groupedBookings[TicketMark.ready] ?? []),
                _buildBookingList(_groupedBookings[TicketMark.aktif] ?? []),
                _buildBookingList(_groupedBookings[TicketMark.selesai] ?? []),
                _buildBookingList(_groupedBookings[TicketMark.belumDibayar] ?? []),
                _buildBookingList(_groupedBookings[TicketMark.dibatalkan] ?? []),
              ],
            ),
          ),
        ],
      ),
    ),
  );
},
);
}

  Widget _buildBookingList(List<Map<String, dynamic>> bookings) {
    if (bookings.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.event_busy, size: 48, color: Color(0xFF76777B)), const SizedBox(height: 12), Text('Tidak ada booking', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF76777B)))]));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final b = bookings[i];
        final statusColor = _getStatusColor(b['status']);
        final statusBg = _getStatusBg(b['status']);
        final vehicleColor = _getVehicleColor(b['vehicle']['type']);

        return GestureDetector(
          onTap: () => _showBookingDetail(b),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DFD5))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFE3EEFF), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(b['user']['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF114177))))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(b['user']['name'], style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      Text(b['location'], style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                    ])),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)), child: Text(b['status'], style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Color(0xFF76777B)),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatTime(b['startTime'])} - ${_formatTime(b['endTime'])}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _buildDetailChip(Icons.local_parking, 'Slot ${b['slot']} (${b['floor']})')),
                  Expanded(child: _buildDetailChip(_getVehicleIcon(b['vehicle']['type']), b['vehicle']['plate'], iconColor: vehicleColor)),
                  Expanded(child: _buildDetailChip(Icons.attach_money, 'Rp ${_formatNumber(b['totalPrice'])}')),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)), child: Text(b['bookingType'], style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF45474A)))),
                  const Spacer(),
                  Text('Bayar: ${b['paymentStatus']}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: b['paymentStatus'] == 'Dibayar' ? const Color(0xFF17A18A) : const Color(0xFFE07A5F))),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailChip(IconData icon, String text, {Color? iconColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor ?? const Color(0xFF76777B)),
        const SizedBox(width: 4),
        Flexible(child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A)), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  String _formatTime(String dt) {
    try {
      final d = DateTime.parse(dt);
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dt;
    }
  }

  Widget _buildStatCard(String label, String value, Color color, Color bg) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: color)), const SizedBox(height: 2), Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: color))])));
  }
}