import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Entry data untuk Cache Balancer
class _CacheEntry<T> {
  final T data;
  final DateTime cachedAt;
  final Duration ttl;

  _CacheEntry({
    required this.data,
    required this.cachedAt,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(cachedAt) > ttl;
}

/// Service Penyeimbang Database (Cache Balancer)
/// Mencegah request berulang kali ke database Supabase untuk data yang sama.
/// Bekerja dengan dual-layer:
/// 1. In-Memory Cache (Ultra cepat, 0 latency)
/// 2. Local SharedPreferences Persistent Cache (Mencegah reload saat buka ulang halaman/aplikasi)
class DatabaseCacheBalancerService {
  DatabaseCacheBalancerService._();
  static final DatabaseCacheBalancerService instance = DatabaseCacheBalancerService._();

  final Map<String, _CacheEntry<dynamic>> _memoryCache = {};

  /// Mengambil data dengan penyeimbang database.
  /// Jika cache masih valid dan [forceRefresh] == false, data dikembalikan langsung tanpa request network.
  /// Jika cache kedaluwarsa atau belum ada, [queryFn] akan dieksekusi dan hasilnya disimpan ke cache.
  Future<T> getBalanced<T>({
    required String queryKey,
    required Future<T> Function() queryFn,
    Duration ttl = const Duration(minutes: 5),
    bool forceRefresh = false,
  }) async {
    // 1. Cek In-Memory Cache
    if (!forceRefresh && _memoryCache.containsKey(queryKey)) {
      final entry = _memoryCache[queryKey]!;
      if (!entry.isExpired && entry.data is T) {
        debugPrint('[CacheBalancer] HIT (Memory): $queryKey');
        return entry.data as T;
      }
    }

    // 2. Cek Persistent Local Cache jika T bertipe Map / List
    if (!forceRefresh && (T == (List<Map<String, dynamic>>) || T == (Map<String, dynamic>))) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final rawJson = prefs.getString('cache_$queryKey');
        final rawTime = prefs.getInt('cache_time_$queryKey');

        if (rawJson != null && rawTime != null) {
          final cachedTime = DateTime.fromMillisecondsSinceEpoch(rawTime);
          if (DateTime.now().difference(cachedTime) <= ttl) {
            final decoded = jsonDecode(rawJson);
            if (decoded is T) {
              debugPrint('[CacheBalancer] HIT (Persistent): $queryKey');
              _memoryCache[queryKey] = _CacheEntry(
                data: decoded,
                cachedAt: cachedTime,
                ttl: ttl,
              );
              return decoded;
            }
          }
        }
      } catch (e) {
        debugPrint('[CacheBalancer] Persistent read error: $e');
      }
    }

    // 3. Request ke Database (MISS atau Forced)
    debugPrint('[CacheBalancer] MISS (Fetch from DB): $queryKey');
    final freshData = await queryFn();

    // 4. Simpan ke Memory Cache
    _memoryCache[queryKey] = _CacheEntry(
      data: freshData,
      cachedAt: DateTime.now(),
      ttl: ttl,
    );

    // 5. Simpan ke Persistent Cache jika serializable JSON
    if (freshData is List || freshData is Map) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cache_$queryKey', jsonEncode(freshData));
        await prefs.setInt('cache_time_$queryKey', DateTime.now().millisecondsSinceEpoch);
      } catch (e) {
        debugPrint('[CacheBalancer] Persistent write error: $e');
      }
    }

    return freshData;
  }

  /// Menghapus cache tertentu saat ada operasi perubahan data (Insert, Update, Delete)
  Future<void> invalidate(String queryKey) async {
    _memoryCache.remove(queryKey);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cache_$queryKey');
      await prefs.remove('cache_time_$queryKey');
      debugPrint('[CacheBalancer] INVALIDATED: $queryKey');
    } catch (_) {}
  }

  /// Menghapus semua cache yang memiliki awalan prefix tertentu (misal: 'parking_', 'user_')
  Future<void> invalidatePrefix(String prefix) async {
    _memoryCache.removeWhere((key, _) => key.startsWith(prefix));
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('cache_$prefix'));
      for (final k in keys) {
        await prefs.remove(k);
      }
      debugPrint('[CacheBalancer] INVALIDATED PREFIX: $prefix');
    } catch (_) {}
  }

  /// Bersihkan seluruh cache
  Future<void> clearAll() async {
    _memoryCache.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('cache_'));
      for (final k in keys) {
        await prefs.remove(k);
      }
      debugPrint('[CacheBalancer] ALL CACHE CLEARED');
    } catch (_) {}
  }
}
