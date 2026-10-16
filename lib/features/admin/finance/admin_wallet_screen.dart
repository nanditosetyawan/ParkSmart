import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminWalletScreen extends StatefulWidget {
  const AdminWalletScreen({super.key});

  @override
  State<AdminWalletScreen> createState() => _AdminWalletScreenState();
}

class _AdminWalletScreenState extends State<AdminWalletScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  int? _selectedAmount = 100000;
  Map<String, dynamic>? _selectedUser;

  final List<Map<String, dynamic>> _users = [
    {
      'id': 'usr-001',
      'name': 'Nanda Setiawan',
      'email': 'nanda.setiawan@gmail.com',
      'phone': '+62 812-3456-7890',
      'balance': 45000,
      'avatar': 'N',
    },
    {
      'id': 'usr-002',
      'name': 'Rafi Maulana',
      'email': 'rafi.maulana@gmail.com',
      'phone': '+62 856-7890-1234',
      'balance': 120000,
      'avatar': 'R',
    },
    {
      'id': 'usr-003',
      'name': 'Siti Rahayu',
      'email': 'siti.rahayu@gmail.com',
      'phone': '+62 878-1122-3344',
      'balance': 15000,
      'avatar': 'S',
    },
    {
      'id': 'usr-004',
      'name': 'Dewi Lestari',
      'email': 'dewi.lestari@gmail.com',
      'phone': '+62 813-9988-7766',
      'balance': 230000,
      'avatar': 'D',
    },
    {
      'id': 'usr-005',
      'name': 'Budi Santoso',
      'email': 'budi.santoso@gmail.com',
      'phone': '+62 821-4455-6677',
      'balance': 0,
      'avatar': 'B',
    },
  ];

  final List<Map<String, dynamic>> _recentInjections = [
    {
      'userName': 'Nanda Setiawan',
      'userEmail': 'nanda.setiawan@gmail.com',
      'amount': 500000,
      'reason': 'Kompensasi kendala barrier gate B2',
      'time': '1 jam lalu',
      'admin': 'Admin Pusat (Dito)',
      'status': 'Berhasil',
    },
    {
      'userName': 'Siti Rahayu',
      'userEmail': 'siti.rahayu@gmail.com',
      'amount': 50000,
      'reason': 'Bonus KYC KTP Terverifikasi',
      'time': '3 jam lalu',
      'admin': 'Sistem Otomatis',
      'status': 'Berhasil',
    },
    {
      'userName': 'Rafi Maulana',
      'userEmail': 'rafi.maulana@gmail.com',
      'amount': 100000,
      'reason': 'Top-up Manual Kasir Kantor Parkir',
      'time': 'Kemarin, 16:40',
      'admin': 'Admin Lokasi (Central Park)',
      'status': 'Berhasil',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedUser = _users.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int get _finalAmount {
    if (_selectedAmount != null) return _selectedAmount!;
    final parsed = int.tryParse(_customAmountController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    return parsed ?? 0;
  }

  String _formatRupiah(int val) {
    final str = val.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  void _confirmInjection() {
    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih pengguna terlebih dahulu')),
      );
      return;
    }
    final amount = _finalAmount;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal injeksi harus lebih dari 0')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD1F2EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_balance_wallet, color: Color(0xFF17A18A), size: 22),
            ),
            const SizedBox(width: 12),
            Text('Konfirmasi Injeksi', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Anda akan menambahkan saldo dompet:', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE4DFD5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pengguna:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                      Text(_selectedUser!['name'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nominal Injeksi:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                      Text(_formatRupiah(amount), style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Saldo Baru:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                      Text(_formatRupiah((_selectedUser!['balance'] as int) + amount), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                    ],
                  ),
                ],
              ),
            ),
            if (_noteController.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Catatan: ${_noteController.text}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontStyle: FontStyle.italic, color: const Color(0xFF76777B))),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFF76777B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _selectedUser!['balance'] = (_selectedUser!['balance'] as int) + amount;
                _recentInjections.insert(0, {
                  'userName': _selectedUser!['name'],
                  'userEmail': _selectedUser!['email'],
                  'amount': amount,
                  'reason': _noteController.text.isEmpty ? 'Injeksi Saldo Manual Admin' : _noteController.text,
                  'time': 'Baru saja',
                  'admin': 'Admin Dito',
                  'status': 'Berhasil',
                });
                _noteController.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF17A18A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  content: Text('Berhasil menginjeksi ${_formatRupiah(amount)} ke ${_selectedUser!['name']}!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF17A18A),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Konfirmasi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Injeksi Saldo User', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Manajemen Dompet Digital ParkSmart', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Stat overview
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE4DFD5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Saldo Beredar', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                      const SizedBox(height: 4),
                      Text('Rp 28.450.000', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      const SizedBox(height: 4),
                      Text('1.240 pengguna aktif berdompet', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF17A18A))),
                    ],
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF114177).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.account_balance_wallet, size: 26, color: Color(0xFF114177)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Header: Pilih Pengguna
          Text('Pilih Pengguna Sasaran', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4DFD5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: _selectedUser,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF76777B)),
                    items: _users.map((u) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: u,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFFF1EEE7),
                              child: Text(u['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(u['name'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                                  Text('${u['email']} · Saldo: ${_formatRupiah(u['balance'])}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedUser = val);
                    },
                  ),
                ),
                if (_selectedUser != null) ...[
                  const Divider(color: Color(0xFFF1EEE7), height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Saldo Saat Ini:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(8)),
                        child: Text(_formatRupiah(_selectedUser!['balance']), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Header: Nominal Injeksi
          Text('Pilih Nominal Injeksi', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [20000, 50000, 100000, 250000, 500000].map((amt) {
              final isSelected = _selectedAmount == amt;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAmount = amt;
                    _customAmountController.clear();
                  });
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width - 60) / 3,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF114177) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? const Color(0xFF114177) : const Color(0xFFE4DFD5)),
                  ),
                  child: Center(
                    child: Text(
                      _formatRupiah(amt),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF1A1A18),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Custom amount
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _selectedAmount == null ? const Color(0xFF114177) : const Color(0xFFE4DFD5)),
            ),
            child: TextField(
              controller: _customAmountController,
              keyboardType: TextInputType.number,
              onTap: () => setState(() => _selectedAmount = null),
              decoration: InputDecoration(
                icon: const Icon(Icons.edit_note, size: 20, color: Color(0xFF76777B)),
                hintText: 'Atau ketik nominal kustom (Rp)...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notes
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE4DFD5)),
            ),
            child: TextField(
              controller: _noteController,
              decoration: InputDecoration(
                icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF76777B)),
                hintText: 'Alasan / Keterangan Injeksi (opsional)...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Button Submit
          ElevatedButton(
            onPressed: _confirmInjection,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF17A18A),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_card, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text('Injeksi Saldo Sekarang', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Section Header: Riwayat Injeksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Riwayat Injeksi Admin', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              Text('${_recentInjections.length} Log', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
            ],
          ),
          const SizedBox(height: 12),

          ..._recentInjections.map((inj) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE4DFD5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1F2EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_outline, size: 20, color: Color(0xFF17A18A)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(inj['userName'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                          Text('+${_formatRupiah(inj['amount'])}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(inj['reason'], style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(inj['admin'], style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                          const Spacer(),
                          Text(inj['time'], style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    ));
  }
}
