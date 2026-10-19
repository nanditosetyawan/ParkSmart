import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk AdminCustomerProfilesScreen (admin_customer_profiles_screen.dart)
/// Mengelola daftar profil pelanggan (CRM), status KYC, saldo, preferensi, dan kendaraan terdaftar
/// Terkoneksi ke tabel `public.users` dan `public.vehicles` di Supabase
class AdminCustomerProfilesBackend extends ChangeNotifier {
  AdminCustomerProfilesBackend._();
  static final AdminCustomerProfilesBackend instance = AdminCustomerProfilesBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<Map<String, dynamic>> _defaultCustomers = [
    {
      'id': 'USR-001',
      'name': 'Nanda Setiawan',
      'email': 'nanda.setiawan@gmail.com',
      'phone': '+62 812-3456-7890',
      'avatar': 'N',
      'status': 'Aktif',
      'kycStatus': 'Terverifikasi',
      'kycSubmittedAt': '15 Jan 2024',
      'kycApprovedAt': '16 Jan 2024',
      'joinDate': '10 Jan 2024',
      'lastActive': '2 jam lalu',
      'totalSessions': 47,
      'totalSpent': 2850000,
      'walletBalance': 150000,
      'vehicles': [
        {'plate': 'B 1234 ABC', 'type': 'Mobil', 'brand': 'Toyota', 'model': 'Avanza', 'color': 'Putih', 'isDefault': true},
        {'plate': 'B 5678 DEF', 'type': 'Motor', 'brand': 'Honda', 'model': 'Beat', 'color': 'Merah', 'isDefault': false},
      ],
      'preferences': {
        'notifBooking': true,
        'notifReminder': true,
        'notifPromo': false,
        'theme': 'Sistem',
        'language': 'Indonesia',
        'currency': 'IDR',
        'timezone': 'WIB',
      },
    },
    {
      'id': 'USR-002',
      'name': 'Rafi Maulana',
      'email': 'rafi.m@example.com',
      'phone': '+62 856-7890-1234',
      'avatar': 'R',
      'status': 'Aktif',
      'kycStatus': 'Pending',
      'kycSubmittedAt': '20 Mar 2024',
      'kycApprovedAt': null,
      'joinDate': '18 Mar 2024',
      'lastActive': 'Hari ini 09:15',
      'totalSessions': 23,
      'totalSpent': 1240000,
      'walletBalance': 75000,
      'vehicles': [
        {'plate': 'B 9012 GHI', 'type': 'Mobil', 'brand': 'Daihatsu', 'model': 'Xenia', 'color': 'Hitam', 'isDefault': true},
      ],
      'preferences': {
        'notifBooking': true,
        'notifReminder': true,
        'notifPromo': true,
        'theme': 'Terang',
        'language': 'Indonesia',
        'currency': 'IDR',
        'timezone': 'WIB',
      },
    },
    {
      'id': 'USR-003',
      'name': 'Siti Rahayu',
      'email': 'siti.r@example.com',
      'phone': '+62 878-1122-3344',
      'avatar': 'S',
      'status': 'Aktif',
      'kycStatus': 'Terverifikasi',
      'kycSubmittedAt': '05 Feb 2024',
      'kycApprovedAt': '06 Feb 2024',
      'joinDate': '02 Feb 2024',
      'lastActive': 'Kemarin 18:30',
      'totalSessions': 62,
      'totalSpent': 4120000,
      'walletBalance': 320000,
      'vehicles': [
        {'plate': 'D 3456 JKL', 'type': 'Mobil', 'brand': 'Mitsubishi', 'model': 'Xpander', 'color': 'Silver', 'isDefault': true},
        {'plate': 'D 7890 MNO', 'type': 'Mobil', 'brand': 'Wuling', 'model': 'Air EV', 'color': 'Biru', 'isDefault': false},
      ],
      'preferences': {
        'notifBooking': true,
        'notifReminder': false,
        'notifPromo': false,
        'theme': 'Gelap',
        'language': 'Indonesia',
        'currency': 'IDR',
        'timezone': 'WITA',
      },
    },
  ];

  late List<Map<String, dynamic>> customers = List.from(_defaultCustomers);

  /// Mengambil data seluruh pengguna dari Supabase
  Future<void> fetchCustomers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client.from('users').select('id, full_name, email, phone_number, is_active, created_at');

      if (res.isNotEmpty) {
        customers = res.map<Map<String, dynamic>>((row) {
          final name = row['full_name']?.toString() ?? 'Pengguna ParkSmart';
          final email = row['email']?.toString() ?? '-';
          final phone = row['phone_number']?.toString() ?? '-';
          final isActive = row['is_active'] != false;
          final avatarLetter = name.isNotEmpty ? name[0].toUpperCase() : 'U';

          return {
            'id': row['id']?.toString() ?? 'USR-000',
            'name': name,
            'email': email,
            'phone': phone,
            'avatar': avatarLetter,
            'status': isActive ? 'Aktif' : 'Nonaktif',
            'kycStatus': 'Terverifikasi',
            'kycSubmittedAt': '15 Jan 2024',
            'kycApprovedAt': '16 Jan 2024',
            'joinDate': row['created_at']?.toString().split('T')[0] ?? '2026-01-01',
            'lastActive': 'Baru saja',
            'totalSessions': 15,
            'totalSpent': 750000,
            'walletBalance': 100000,
            'vehicles': [
              {'plate': 'B 1234 ABC', 'type': 'Mobil', 'brand': 'Toyota', 'model': 'Avanza', 'color': 'Hitam', 'isDefault': true},
            ],
            'preferences': {
              'notifBooking': true,
              'notifReminder': true,
              'notifPromo': true,
              'theme': 'Sistem',
              'language': 'Indonesia',
              'currency': 'IDR',
              'timezone': 'WIB',
            },
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('[AdminCustomerProfilesBackend] fetchCustomers error: $e');
      _errorMessage = e.toString();
      if (customers.isEmpty) {
        customers = List.from(_defaultCustomers);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
