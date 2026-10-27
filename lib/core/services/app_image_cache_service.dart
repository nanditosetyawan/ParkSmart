import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'database_cache_balancer_service.dart';

/// Service penyimpanan & caching gambar di disk perangkat (local storage) & memori
/// Mencegah request berulang ke database / server storage untuk menghemat kuota & mempercepat load
class AppImageCacheService {
  AppImageCacheService._();
  static final AppImageCacheService instance = AppImageCacheService._();

  Directory? _cacheDir;
  final Map<String, Uint8List> _memoryCache = {};

  /// Mengambil atau menginisialisasi direktori cache penyimpanan gambar di perangkat
  Future<Directory> getCacheDirectory() async {
    if (_cacheDir != null && _cacheDir!.existsSync()) {
      return _cacheDir!;
    }
    final temp = await getTemporaryDirectory();
    final dir = Directory('${temp.path}/parksmart_image_cache');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    _cacheDir = dir;
    return dir;
  }

  /// Menghasilkan nama file cache unik berbasis hash MD5 dari URL
  String _urlToKey(String url) {
    final clean = url.trim();
    final digest = md5.convert(utf8.encode(clean)).toString();
    return digest;
  }

  /// Mengambil bytes langsung dari cache memori jika sudah pernah diakses
  Uint8List? getMemoryCached(String url) {
    if (url.isEmpty) return null;
    return _memoryCache[url];
  }

  /// Mengambil file cache lokal jika sudah tersimpan di disk
  Future<File?> getCachedFile(String url) async {
    if (url.isEmpty || (!url.startsWith('http://') && !url.startsWith('https://'))) {
      return null;
    }
    try {
      final dir = await getCacheDirectory();
      final key = _urlToKey(url);
      final file = File('${dir.path}/$key.cache');
      if (file.existsSync() && file.lengthSync() > 0) {
        return file;
      }
    } catch (_) {}
    return null;
  }

  /// Mengambil data gambar (Uint8List). Prioritas:
  /// 1. Memori RAM (Instant)
  /// 2. Disk Storage Perangkat (Offline/Local)
  /// 3. Request ke Jaringan -> lalu simpan ke disk & memori
  Future<Uint8List?> getImageBytes(String url) async {
    if (url.isEmpty) return null;

    // 1. Cek Memori
    if (_memoryCache.containsKey(url)) {
      return _memoryCache[url];
    }

    try {
      final dir = await getCacheDirectory();
      final key = _urlToKey(url);
      final file = File('${dir.path}/$key.cache');

      // 2. Cek Disk Cache
      if (file.existsSync() && file.lengthSync() > 0) {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          _memoryCache[url] = bytes;
          return bytes;
        }
      }

      // 3. Unduh dari Jaringan & Simpan ke Disk
      if (url.startsWith('http://') || url.startsWith('https://')) {
        final response = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 15),
          onTimeout: () => http.Response('', 408),
        );

        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          final bytes = response.bodyBytes;
          await file.writeAsBytes(bytes, flush: true);
          _memoryCache[url] = bytes;
          return bytes;
        }
      } else if (!kIsWeb && File(url).existsSync()) {
        final bytes = await File(url).readAsBytes();
        _memoryCache[url] = bytes;
        return bytes;
      }
    } catch (e) {
      debugPrint('[AppImageCacheService] Gagal memuat/menyimpan cache gambar: $e');
    }
    return null;
  }

  /// Menghitung total ukuran cache gambar di disk perangkat dalam satuan bytes
  Future<int> getCacheSizeBytes() async {
    try {
      final dir = await getCacheDirectory();
      if (!dir.existsSync()) return 0;

      int total = 0;
      final entities = dir.listSync(recursive: true, followLinks: false);
      for (final entity in entities) {
        if (entity is File) {
          total += entity.lengthSync();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Menghasilkan format string ukuran cache untuk UI (misal: "2.4 MB tersimpan", "150 KB tersimpan", "0 KB tersimpan")
  Future<String> getFormattedCacheSize() async {
    final bytes = await getCacheSizeBytes();
    if (bytes <= 0) {
      return '0 KB tersimpan';
    }
    if (bytes < 1024 * 1024) {
      final kb = (bytes / 1024).toStringAsFixed(1);
      return '$kb KB tersimpan';
    }
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
    return '$mb MB tersimpan';
  }

  /// Membersihkan seluruh file cache gambar dari penyimpanan perangkat & memori
  /// Sekaligus membersihkan cache balancer database
  Future<bool> clearAllCache() async {
    try {
      // 1. Bersihkan memory cache
      _memoryCache.clear();

      // 2. Bersihkan disk cache gambar
      final dir = await getCacheDirectory();
      if (dir.existsSync()) {
        final entities = dir.listSync();
        for (final entity in entities) {
          try {
            entity.deleteSync(recursive: true);
          } catch (_) {}
        }
      }

      // 3. Bersihkan cache rendering engine Flutter
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // 4. Bersihkan cache database balancer
      DatabaseCacheBalancerService.instance.clearAll();

      debugPrint('[AppImageCacheService] Seluruh cache perangkat berhasil dibersihkan.');
      return true;
    } catch (e) {
      debugPrint('[AppImageCacheService] Gagal membersihkan cache: $e');
      return false;
    }
  }

  /// ImageProvider khusus untuk CircleAvatar atau DecorationImage yang otomatis membaca cache disk
  AppCachedImageProvider provider(String url, {double scale = 1.0}) {
    return AppCachedImageProvider(url, scale: scale);
  }
}

/// ImageProvider yang mengambil gambar dari cache perangkat
class AppCachedImageProvider extends ImageProvider<AppCachedImageProvider> {
  final String url;
  final double scale;

  const AppCachedImageProvider(this.url, {this.scale = 1.0});

  @override
  Future<AppCachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AppCachedImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(AppCachedImageProvider key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => [
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<AppCachedImageProvider>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(AppCachedImageProvider key, ImageDecoderCallback decode) async {
    final bytes = await AppImageCacheService.instance.getImageBytes(key.url);
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Gagal memuat gambar: ${key.url}');
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AppCachedImageProvider && other.url == url && other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'AppCachedImageProvider')}("$url", scale: $scale)';
}

/// Widget drop-in untuk menggantikan Image.network agar otomatis disimpan di cache perangkat
class AppCachedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Alignment alignment;

  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorBuilder,
    this.alignment = Alignment.center,
  });

  @override
  State<AppCachedNetworkImage> createState() => _AppCachedNetworkImageState();
}

class _AppCachedNetworkImageState extends State<AppCachedNetworkImage> {
  Uint8List? _bytes;
  bool _hasError = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(AppCachedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.imageUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
      return;
    }

    final mem = AppImageCacheService.instance.getMemoryCached(widget.imageUrl);
    if (mem != null && mem.isNotEmpty) {
      if (mounted) {
        setState(() {
          _bytes = mem;
          _hasError = false;
        });
      }
      return;
    }

    setState(() {
      _hasError = false;
    });

    try {
      final bytes = await AppImageCacheService.instance.getImageBytes(widget.imageUrl);
      if (!mounted) return;
      if (bytes != null && bytes.isNotEmpty) {
        setState(() {
          _bytes = bytes;
          _hasError = false;
        });
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_bytes != null && _bytes!.isNotEmpty) {
      content = Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        errorBuilder: widget.errorBuilder ?? (context, err, stack) => _defaultPlaceholder(),
      );
    } else if (_hasError) {
      content = widget.errorBuilder?.call(context, _error ?? Exception('Load failed'), null) ??
          _defaultPlaceholder();
    } else {
      content = widget.placeholder ?? _defaultPlaceholder();
    }

    if (widget.borderRadius != null) {
      content = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    return content;
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: const Color(0xFFF1EEE7),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Color(0xFF9CA3AF), size: 24),
      ),
    );
  }
}
