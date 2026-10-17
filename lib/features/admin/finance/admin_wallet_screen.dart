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
  final TextEditingController _userIdSearchController = TextEditingController();

  int? _selectedAmount = 100000;
  Map<String, dynamic>? _selectedUser;
  String _userSearchQuery = '';

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
    {
      'id': 'usr-006',
      'name': 'Ahmad Fauzi',
      'email': 'ahmad.fauzi@gmail.com',
      'phone': '+62 812-9911-2233',
      'balance': 85000,
      'avatar': 'A',
    },
    {
      'id': 'usr-007',
      'name': 'Linda Wijaya',
      'email': 'linda.wijaya@gmail.com',
      'phone': '+62 818-4455-6677',
      'balance': 310000,
      'avatar': 'L',
    },
    {
      'id': 'usr-008',
      'name': 'Rizky Pratama',
      'email': 'rizky.pratama@gmail.com',
      'phone': '+62 877-3322-1100',
      'balance': 12500,
      'avatar': 'R',
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
    _userIdSearchController.text = _selectedUser!['id'].toString().toUpperCase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customAmountController.dispose();
    _noteController.dispose();
    _userIdSearchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_userSearchQuery.isEmpty) return _users;
    final q = _userSearchQuery.toLowerCase();
    final cleanQ = q.replaceAll('usr-', '').replaceAll('-', '');
    return _users.where((u) {
      final id = u['id'].toString().toLowerCase();
      final cleanId = id.replaceAll('usr-', '').replaceAll('-', '');
      final name = u['name'].toString().toLowerCase();
      final email = u['email'].toString().toLowerCase();
      return id.contains(q) || cleanId.contains(cleanQ) || name.contains(q) || email.contains(q);
    }).toList();
  }

  void _openUserSearchModal() {
    final searchCtrl = TextEditingController(text: _userSearchQuery);
    List<Map<String, dynamic>> filtered = _filteredUsers;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
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
                          Text('Cari Pengguna ParkSmart', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                          Text('Cari berdasarkan ID User (cth: usr-001) atau Nama', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                        ],
                      ),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Color(0xFF76777B))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1A1A18)),
                    decoration: InputDecoration(
                      hintText: 'Ketik ID User (cth: usr-001, 002) atau Nama...',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
                      prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF114177)),
                      suffixIcon: searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                setModalState(() {
                                  searchCtrl.clear();
                                  filtered = List.from(_users);
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF114177), width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onChanged: (val) {
                      final q = val.trim().toLowerCase();
                      final cleanQ = q.replaceAll('usr-', '').replaceAll('-', '');
                      setModalState(() {
                        filtered = _users.where((u) {
                          final id = u['id'].toString().toLowerCase();
                          final cleanId = id.replaceAll('usr-', '').replaceAll('-', '');
                          final name = u['name'].toString().toLowerCase();
                          final email = u['email'].toString().toLowerCase();
                          return id.contains(q) || cleanId.contains(cleanQ) || name.contains(q) || email.contains(q);
                        }).toList();
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.45),
                    child: filtered.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text('Tidak ada user dengan ID atau nama tersebut', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => const Divider(color: Color(0xFFF3F4F6), height: 1),
                            itemBuilder: (ctx, idx) {
                              final u = filtered[idx];
                              final isSelected = _selectedUser?['id'] == u['id'];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isSelected ? const Color(0xFF114177) : const Color(0xFFE3EEFF),
                                  child: Text(u['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF114177))),
                                ),
                                title: Row(
                                  children: [
                                    Text(u['name'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0xFF114177).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                      child: Text(u['id'].toString().toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                                    ),
                                  ],
                                ),
                                subtitle: Text('${u['email']} · Saldo: ${_formatRupiah(u['balance'])}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle, color: Color(0xFF17A18A), size: 20)
                                    : const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E), size: 18),
                                onTap: () {
                                  setState(() {
                                    _selectedUser = u;
                                    _userIdSearchController.text = u['id'].toString().toUpperCase();
                                    _userSearchQuery = '';
                                  });
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ID Pengguna:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF114177).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(_selectedUser!['id'].toString().toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nama Pengguna:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
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
              border: Border.all(color: const Color(0xFFE5E7EB)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pilih Pengguna Sasaran', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              TextButton.icon(
                onPressed: _openUserSearchModal,
                icon: const Icon(Icons.people_alt_outlined, size: 16, color: Color(0xFF114177)),
                label: Text('Daftar User', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
              ),
            ],
          ),
          const SizedBox(height: 6),

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
                // 1. Search Box by ID or Name
                TextField(
                  controller: _userIdSearchController,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1A1A18)),
                  decoration: InputDecoration(
                    labelText: 'Cari ID User / Nama Pengguna',
                    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
                    hintText: 'Ketik ID (cth: usr-001) atau Nama...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF9E9E9E)),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF114177)),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_userIdSearchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Color(0xFF76777B)),
                            onPressed: () {
                              setState(() {
                                _userIdSearchController.clear();
                                _userSearchQuery = '';
                              });
                            },
                          ),
                        IconButton(
                          tooltip: 'Buka Pencarian Lengkap',
                          icon: const Icon(Icons.tune, size: 18, color: Color(0xFF114177)),
                          onPressed: _openUserSearchModal,
                        ),
                      ],
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF114177), width: 1.5)),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _userSearchQuery = val.trim().toLowerCase();
                      if (_userSearchQuery.isNotEmpty) {
                        final matches = _filteredUsers;
                        if (matches.length == 1) {
                          _selectedUser = matches.first;
                        }
                      }
                    });
                  },
                ),

                // 2. Quick Search Results dropdown if typing
                if (_userSearchQuery.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 180),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: _filteredUsers.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(14),
                            child: Center(
                              child: Text(
                                'User dengan ID atau nama "$_userSearchQuery" tidak ditemukan',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: _filteredUsers.length,
                            separatorBuilder: (_, _) => const Divider(color: Color(0xFFE5E7EB), height: 1),
                            itemBuilder: (_, idx) {
                              final u = _filteredUsers[idx];
                              final isCurSelected = _selectedUser?['id'] == u['id'];
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedUser = u;
                                    _userSearchQuery = '';
                                    _userIdSearchController.text = u['id'].toString().toUpperCase();
                                  });
                                },
                                child: Container(
                                  color: isCurSelected ? const Color(0xFF114177).withValues(alpha: 0.08) : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: const Color(0xFFE3EEFF),
                                        child: Text(u['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(u['name'], style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                  decoration: BoxDecoration(color: const Color(0xFF114177).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                                  child: Text(u['id'].toString().toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                                                ),
                                              ],
                                            ),
                                            Text('${u['email']} · Saldo: ${_formatRupiah(u['balance'])}', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF76777B))),
                                          ],
                                        ),
                                      ),
                                      if (isCurSelected)
                                        const Icon(Icons.check, size: 16, color: Color(0xFF17A18A)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],

                // 3. User Selected Card Preview
                if (_selectedUser != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF114177).withValues(alpha: 0.12),
                          child: Text(_selectedUser!['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(_selectedUser!['name'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)), overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFF114177), borderRadius: BorderRadius.circular(5)),
                                    child: Text(_selectedUser!['id'].toString().toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('${_selectedUser!['email']} · ${_selectedUser!['phone']}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('Saldo Saat Ini: ', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                                  Text(_formatRupiah(_selectedUser!['balance']), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Pilih Pengguna Lain',
                          icon: const Icon(Icons.swap_vert_circle_outlined, color: Color(0xFF114177), size: 24),
                          onPressed: _openUserSearchModal,
                        ),
                      ],
                    ),
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
                    border: Border.all(color: isSelected ? const Color(0xFF114177) : const Color(0xFFE5E7EB)),
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
              border: Border.all(color: _selectedAmount == null ? const Color(0xFF114177) : const Color(0xFFE5E7EB)),
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
              border: Border.all(color: const Color(0xFFE5E7EB)),
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
              border: Border.all(color: const Color(0xFFE5E7EB)),
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
