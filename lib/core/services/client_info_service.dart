import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model data log aktivitas login admin
class AdminLoginLog {
  final String id;
  final String admin;
  final String email;
  final String role;
  final String action;
  final String device;
  final String ip;
  final String location;
  final String isp;
  final String time;
  final DateTime timestamp;
  final String status;
  final bool isCurrentSession;
  final bool syncedToSupabase;

  AdminLoginLog({
    required this.id,
    required this.admin,
    this.email = 'superadmin@parksmart.id',
    required this.role,
    required this.action,
    required this.device,
    required this.ip,
    this.location = 'Indonesia',
    this.isp = 'Internet Provider',
    required this.time,
    required this.timestamp,
    required this.status,
    this.isCurrentSession = false,
    this.syncedToSupabase = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'admin': admin,
    'email': email,
    'role': role,
    'action': action,
    'device': device,
    'ip': ip,
    'location': location,
    'isp': isp,
    'time': time,
    'timestamp': timestamp.toIso8601String(),
    'status': status,
    'isCurrentSession': isCurrentSession,
    'syncedToSupabase': syncedToSupabase,
  };

  factory AdminLoginLog.fromJson(Map<String, dynamic> map) {
    return AdminLoginLog(
      id: map['id'] ?? 'LOG-000',
      admin: map['admin'] ?? 'Admin',
      email: map['email'] ?? map['admin_email'] ?? 'superadmin@parksmart.id',
      role: map['role'] ?? 'Staff Admin',
      action: map['action'] ?? 'Login berhasil',
      device: map['device'] ?? 'Perangkat',
      ip: map['ip'] ?? '127.0.0.1',
      location: map['location'] ?? 'Indonesia',
      isp: map['isp'] ?? 'Internet Provider',
      time: map['time'] ?? 'Baru saja',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      status: map['status'] ?? 'Berhasil',
      isCurrentSession: map['isCurrentSession'] ?? false,
      syncedToSupabase: map['syncedToSupabase'] ?? false,
    );
  }
}

/// Service untuk deteksi Client Public IP & Info Perangkat (Cara 1)
/// Serta mencatat Audit Log ke SharedPreferences & Supabase REST API
class ClientInfoService {
  static final ClientInfoService _instance = ClientInfoService._internal();
  factory ClientInfoService() => _instance;
  static ClientInfoService get instance => _instance;
  ClientInfoService._internal();

  static const String _kStorageKey = 'parksmart_admin_audit_logs';

  // Cache in-memory
  String? _cachedIp;
  String? _cachedLocation;
  String? _cachedIsp;
  String? _cachedDeviceName;

  /// Mengambil data jaringan publik client (IP Publik, Kota, ISP)
  /// Menggunakan lookup gratis (api.ipify.org + ip-api.com) tanpa server tambahan.
  Future<Map<String, String>> fetchClientNetworkInfo({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedIp != null && _cachedIp!.isNotEmpty) {
      return {
        'ip': _cachedIp!,
        'location': _cachedLocation ?? 'Indonesia',
        'isp': _cachedIsp ?? 'Jaringan Aktif',
      };
    }

    String ip = '127.0.0.1';
    String location = 'Indonesia';
    String isp = 'Jaringan Aktif';

    // 1. Ambil IP publik via api.ipify.org (Sangat andal & cepat)
    try {
      final res = await http
          .get(Uri.parse('https://api.ipify.org?format=json'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['ip'] != null && data['ip'].toString().isNotEmpty) {
          ip = data['ip'].toString();
        }
      }
    } catch (_) {
      // Fallback cadangan jika ipify timeout
    }

    // 2. Lengkapi info Kota & ISP via ip-api.com
    try {
      final resGeo = await http
          .get(Uri.parse('http://ip-api.com/json/'))
          .timeout(const Duration(seconds: 4));
      if (resGeo.statusCode == 200) {
        final geo = jsonDecode(resGeo.body);
        if (geo['status'] == 'success') {
          final city = geo['city'] ?? '';
          final country = geo['country'] ?? '';
          location = (city.isNotEmpty && country.isNotEmpty)
              ? '$city, $country'
              : (city.isNotEmpty ? city : (country.isNotEmpty ? country : 'Indonesia'));
          isp = geo['isp'] ?? isp;
          if (ip == '127.0.0.1' && geo['query'] != null) {
            ip = geo['query'];
          }
        }
      }
    } catch (_) {
      // Silent error fallback
    }

    _cachedIp = ip;
    _cachedLocation = location;
    _cachedIsp = isp;

    return {
      'ip': ip,
      'location': location,
      'isp': isp,
    };
  }

  /// Mendeteksi nama riil model perangkat (Vivo, Samsung, Asus Vivobook, dll)
  Future<String> getDeviceModel({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedDeviceName != null && _cachedDeviceName!.isNotEmpty) {
      return _cachedDeviceName!;
    }

    if (kIsWeb) {
      _cachedDeviceName = 'Web Browser (Chrome/Edge)';
      return _cachedDeviceName!;
    }

    try {
      if (Platform.isWindows) {
        try {
          final result = await Process.run(
            'powershell',
            ['-NoProfile', '-Command', '(Get-CimInstance -ClassName Win32_ComputerSystem).Model'],
          ).timeout(const Duration(seconds: 3));
          final model = result.stdout.toString().trim();
          if (model.isNotEmpty) {
            _cachedDeviceName = '$model (Windows)';
            return _cachedDeviceName!;
          }
        } catch (_) {}

        final host = Platform.localHostname;
        _cachedDeviceName = host.isNotEmpty ? '$host (Windows)' : 'Windows PC';
        return _cachedDeviceName!;
      }

      if (Platform.isAndroid) {
        String brand = '';
        String model = '';
        try {
          final brandRes = await Process.run('getprop', ['ro.product.brand']).timeout(const Duration(seconds: 2));
          brand = brandRes.stdout.toString().trim();
        } catch (_) {}

        try {
          final modelRes = await Process.run('getprop', ['ro.product.model']).timeout(const Duration(seconds: 2));
          model = modelRes.stdout.toString().trim();
        } catch (_) {}

        if (model.isNotEmpty) {
          if (brand.isNotEmpty && !model.toLowerCase().contains(brand.toLowerCase())) {
            _cachedDeviceName = '${_capitalize(brand)} $model';
          } else {
            _cachedDeviceName = model;
          }
          return _cachedDeviceName!;
        }

        final host = Platform.localHostname;
        if (host.isNotEmpty && host != 'localhost') {
          _cachedDeviceName = '$host (Android)';
          return _cachedDeviceName!;
        }
        _cachedDeviceName = 'Vivo Smartphone (Android)';
        return _cachedDeviceName!;
      }

      if (Platform.isIOS) {
        _cachedDeviceName = 'Apple iPhone (iOS)';
        return _cachedDeviceName!;
      }

      if (Platform.isMacOS) {
        _cachedDeviceName = 'Apple Mac (macOS)';
        return _cachedDeviceName!;
      }

      if (Platform.isLinux) {
        _cachedDeviceName = 'Linux Desktop';
        return _cachedDeviceName!;
      }
    } catch (_) {}

    _cachedDeviceName = 'Perangkat Cerdas (Mobile)';
    return _cachedDeviceName!;
  }

  /// Format huruf pertama kapital
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  /// Mencatat event Login Admin dengan IP dan Perangkat Riil (Cara 1)
  /// Menyimpan ke SharedPreferences dan mencoba kirim ke Supabase REST endpoint
  Future<AdminLoginLog> recordAdminLogin({
    required String adminName,
    String adminEmail = 'superadmin@parksmart.id',
    required String role,
    String action = 'Login berhasil (Sesi Aktif)',
  }) async {
    final netInfo = await fetchClientNetworkInfo();
    final device = await getDeviceModel();

    final now = DateTime.now();
    final id = 'LOG-${now.millisecondsSinceEpoch.toString().substring(7)}';

    final log = AdminLoginLog(
      id: id,
      admin: adminName,
      email: adminEmail,
      role: role,
      action: action,
      device: device,
      ip: netInfo['ip'] ?? '127.0.0.1',
      location: netInfo['location'] ?? 'Indonesia',
      isp: netInfo['isp'] ?? 'Internet Provider',
      time: 'Baru saja',
      timestamp: now,
      status: 'Berhasil (Real-Time)',
      isCurrentSession: true,
      syncedToSupabase: false,
    );

    // 1. Simpan ke Local Storage (SharedPreferences)
    await _insertLocalLog(log);

    // 2. Coba kirim langsung ke Supabase jika URL & Key tersedia
    _tryInsertToSupabase(log);

    return log;
  }

  /// Mengambil riwayat seluruh log audit langsung dari Supabase Database
  /// dengan fallback ke SharedPreferences jika offline
  Future<List<AdminLoginLog>> getStoredLogs() async {
    // 1. Ambil data real-time dari Supabase
    try {
      final response = await Supabase.instance.client
          .from('admin_audit_logs')
          .select('id, admin_name, admin_email, role, action, device_model, ip_address, location, isp, status, created_at')
          .order('created_at', ascending: false)
          .limit(50);

      if (response.isNotEmpty) {
        final logs = response.map<AdminLoginLog>((row) {
          final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now();
          return AdminLoginLog(
            id: row['id']?.toString() ?? 'LOG-000',
            admin: row['admin_name']?.toString() ?? 'Admin',
            email: row['admin_email']?.toString() ?? 'superadmin@parksmart.id',
            role: row['role']?.toString() ?? 'Super Admin',
            action: row['action']?.toString() ?? 'Login berhasil',
            device: row['device_model']?.toString() ?? 'Perangkat Cerdas',
            ip: row['ip_address']?.toString() ?? '127.0.0.1',
            location: row['location']?.toString() ?? 'Indonesia',
            isp: row['isp']?.toString() ?? 'Internet Provider',
            time: _formatRelativeTime(createdAt),
            timestamp: createdAt,
            status: row['status']?.toString() ?? 'Berhasil',
            isCurrentSession: false,
            syncedToSupabase: true,
          );
        }).toList();

        // Tandai log paling atas sebagai Sesi Anda saat ini jika masih baru (< 2 jam)
        if (logs.isNotEmpty) {
          final first = logs.first;
          final diff = DateTime.now().difference(first.timestamp);
          if (diff.inHours < 2) {
            logs[0] = AdminLoginLog(
              id: first.id,
              admin: first.admin,
              role: first.role,
              action: first.action.contains('(Sesi Aktif)') ? first.action : '${first.action} (Sesi Aktif)',
              device: first.device,
              ip: first.ip,
              location: first.location,
              isp: first.isp,
              time: 'Baru saja',
              timestamp: first.timestamp,
              status: 'Berhasil (Real-Time)',
              isCurrentSession: true,
              syncedToSupabase: true,
            );
          }
        }

        // Cache ke local SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kStorageKey, jsonEncode(logs.map((e) => e.toJson()).toList()));

        return logs;
      }
    } catch (e) {
      debugPrint('[ClientInfoService] Supabase read error: $e. Falling back to local cache.');
    }

    // 2. Fallback ke SharedPreferences jika offline
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_kStorageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((e) => AdminLoginLog.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (_) {}

    // Default Seed Logs jika belum ada penyimpanan lokal
    return _getDefaultSeedLogs();
  }

  /// Menyimpan log baru ke daftar di SharedPreferences
  Future<void> _insertLocalLog(AdminLoginLog newLog) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_kStorageKey);
      List<AdminLoginLog> logs = [];
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        logs = list.map((e) => AdminLoginLog.fromJson(Map<String, dynamic>.from(e))).toList();
      } else {
        logs = _getDefaultSeedLogs();
      }

      // Jadikan log lama isCurrentSession = false
      final updatedLogs = logs.map((l) => AdminLoginLog(
        id: l.id,
        admin: l.admin,
        role: l.role,
        action: l.action.replaceAll(' (Sesi Aktif)', ''),
        device: l.device,
        ip: l.ip,
        location: l.location,
        isp: l.isp,
        time: _formatRelativeTime(l.timestamp),
        timestamp: l.timestamp,
        status: l.status,
        isCurrentSession: false,
        syncedToSupabase: l.syncedToSupabase,
      )).toList();

      // Sisipkan di paling atas (index 0)
      updatedLogs.insert(0, newLog);

      // Batasi maksimum 50 log terakhir
      if (updatedLogs.length > 50) {
        updatedLogs.removeRange(50, updatedLogs.length);
      }

      await prefs.setString(_kStorageKey, jsonEncode(updatedLogs.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  /// Pangkas log lama (> 7 hari atau simpan hanya 3 teratas)
  Future<void> pruneOldLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_kStorageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        if (list.length > 3) {
          final pruned = list.sublist(0, 3);
          await prefs.setString(_kStorageKey, jsonEncode(pruned));
        }
      }
      // Hapus log lama di Supabase lebih dari 7 hari
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
      await Supabase.instance.client
          .from('admin_audit_logs')
          .delete()
          .lt('created_at', sevenDaysAgo);
    } catch (_) {}
  }

  /// Hapus seluruh log
  Future<void> clearAllLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kStorageKey);
      await Supabase.instance.client
          .from('admin_audit_logs')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000');
    } catch (_) {}
  }

  /// Mengirim record audit log ke Supabase Database (`public.admin_audit_logs`)
  Future<bool> _tryInsertToSupabase(AdminLoginLog log) async {
    try {
      await Supabase.instance.client.from('admin_audit_logs').insert({
        'admin_name': log.admin,
        'admin_email': log.email,
        'role': log.role,
        'action': log.action,
        'device_model': log.device,
        'ip_address': log.ip,
        'location': log.location,
        'isp': log.isp,
        'status': log.status,
        'created_at': log.timestamp.toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('[ClientInfoService] Insert to Supabase error: $e');
      return false;
    }
  }

  /// Format waktu relatif
  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  /// Data seed awal jika baru pertama dibuka
  List<AdminLoginLog> _getDefaultSeedLogs() {
    return [
      AdminLoginLog(
        id: 'LOG-002',
        admin: 'Rina Wijaya',
        role: 'Admin Operasional',
        action: 'Login berhasil',
        device: 'Vivo Y65 (Android)',
        ip: '114.122.45.19',
        location: 'Surabaya, Indonesia',
        isp: 'PT Telkom Indonesia',
        time: '28 mnt lalu',
        timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
        status: 'Berhasil',
      ),
      AdminLoginLog(
        id: 'LOG-003',
        admin: 'Bambang Sutrisno',
        role: 'Admin Finansial',
        action: 'Login berhasil',
        device: 'Samsung Galaxy A54',
        ip: '180.252.88.74',
        location: 'Bandung, Indonesia',
        isp: 'Biznet Networks',
        time: '2 jam lalu',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'Berhasil',
      ),
      AdminLoginLog(
        id: 'LOG-004',
        admin: 'Siti Rahma',
        role: 'Admin CS & KYC',
        action: 'Login berhasil',
        device: 'Xiaomi Redmi Note 12',
        ip: '36.85.190.21',
        location: 'Semarang, Indonesia',
        isp: 'Indosat Ooredoo Hutchison',
        time: '4 jam lalu',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        status: 'Berhasil',
      ),
    ];
  }
}
