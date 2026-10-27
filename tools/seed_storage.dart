import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

Map<String, String> loadEnv() {
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('Error: File .env tidak ditemukan.');
    exit(1);
  }

  final lines = envFile.readAsLinesSync();
  final env = <String, String>{};
  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final idx = line.indexOf('=');
    if (idx != -1) {
      final key = line.substring(0, idx).trim();
      final val = line.substring(idx + 1).trim();
      env[key] = val;
    }
  }
  return env;
}

void main() async {
  print('===============================================================');
  print('🚀 PARKSMART STORAGE & DATABASE SEEDER (DART)');
  print('===============================================================');

  final env = loadEnv();
  final supabaseUrl = env['SUPABASE_URL'] ?? '';
  final supabaseKey = env['SUPABASE_SERVICE_ROLE_KEY'] ?? env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    print('Error: SUPABASE_URL atau SUPABASE_ANON_KEY tidak ditemukan di .env');
    exit(1);
  }

  print('Target Supabase: $supabaseUrl');

  final baseDir = Directory('seed_assets');
  final storageDir = Directory('seed_assets/storage');
  final dataDir = Directory('seed_assets/data');

  if (!baseDir.existsSync() || !storageDir.existsSync()) {
    print('Error: Folder seed_assets/ atau seed_assets/storage/ belum ada.');
    exit(1);
  }

  final buckets = ['avatars', 'vehicles', 'parking-locations', 'kyc-documents'];

  // 1. Validasi & Buat Bucket di Storage
  print('\n1. MEMBUAT BUCKET DI SUPABASE STORAGE...');
  for (var bucket in buckets) {
    final bucketUrl = Uri.parse('$supabaseUrl/storage/v1/bucket');
    try {
      final resp = await http.post(
        bucketUrl,
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': bucket,
          'name': bucket,
          'public': true,
          'file_size_limit': 52428800,
        }),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        print('[Bucket] Sukses membuat bucket: $bucket');
      } else {
        print('[Bucket] Bucket siap / sudah ada: $bucket (${resp.statusCode})');
      }
    } catch (e) {
      print('[Bucket] Warning $bucket: $e');
    }
  }

  // 2. Upload Seluruh File Fisik dari seed_assets/storage/
  print('\n2. MENGUNGGAH SELURUH FILE FISIK KE STORAGE...');
  for (var bucket in buckets) {
    final bucketFolder = Directory('${storageDir.path}/$bucket');
    if (!bucketFolder.existsSync()) continue;

    final entities = bucketFolder.listSync(recursive: true);
    for (var entity in entities) {
      if (entity is File) {
        final relativePath = entity.path
            .substring(bucketFolder.path.length + 1)
            .replaceAll('\\', '/');

        final uploadUrl = Uri.parse('$supabaseUrl/storage/v1/object/$bucket/$relativePath');
        final bytes = await entity.readAsBytes();

        try {
          final resp = await http.post(
            uploadUrl,
            headers: {
              'apikey': supabaseKey,
              'Authorization': 'Bearer $supabaseKey',
              'Content-Type': 'image/jpeg',
              'x-upsert': 'true',
            },
            body: bytes,
          );

          if (resp.statusCode == 200 || resp.statusCode == 201) {
            print('[Upload] Sukses: $bucket/$relativePath');
          } else {
            print('[Upload] Gagal ($bucket/$relativePath): ${resp.statusCode} ${resp.body}');
          }
        } catch (e) {
          print('[Upload] Error ($bucket/$relativePath): $e');
        }
      }
    }
  }

  // 3. Masukkan Seluruh Data Tabel
  print('\n3. MENYINKRONKAN DATA TABEL KE POSTGRESQL...');
  final tableOrder = [
    'users',
    'admins',
    'system_settings',
    'vehicles',
    'parking_locations',
    'parking_slots',
    'user_kyc',
    'user_member_cards',
    'user_favorites',
    'bookings',
    'parking_sessions',
    'payments',
    'system_notifications',
    'admin_audit_logs',
    'arcade_scores',
    'customer_feedbacks'
  ];

  const originalUrl = "https://necsdylhtswrrqassvzp.supabase.co";

  for (var table in tableOrder) {
    final jsonFile = File('${dataDir.path}/$table.json');
    if (!jsonFile.existsSync()) continue;

    var content = await jsonFile.readAsString();
    // Ganti URL Supabase lama ke target saat ini
    content = content.replaceAll(originalUrl, supabaseUrl);

    final List<dynamic> data = jsonDecode(content);
    if (data.isEmpty) {
      print('[Database] $table: 0 data.');
      continue;
    }

    final tableUrl = Uri.parse('$supabaseUrl/rest/v1/$table');
    try {
      final resp = await http.post(
        tableUrl,
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
          'Content-Type': 'application/json',
          'Prefer': 'resolution=merge-duplicates',
        },
        body: content,
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        print('[Database] Sukses upsert ${data.length} baris ke [$table]');
      } else {
        print('[Database] Respon [$table]: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      print('[Database] Error [$table]: $e');
    }
  }

  print('\n===============================================================');
  print('✅ SEEDING SELESAI DENGAN SUKSES! SEMUA DATA DAN STORAGE SIAP.');
  print('===============================================================');
}
