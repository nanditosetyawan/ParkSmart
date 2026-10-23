import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/services/notification_service.dart';
import 'core/services/currency_service.dart';
import 'core/services/theme_service.dart';
import 'core/services/maintenance_service.dart';
import 'core/services/session_service.dart';
import 'theme/app_theme.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/language_service.dart';
import 'features/auth/login_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Muat environment variables dari file .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Gagal load .env via file: $e');
  }

  // 2. Pastikan dotenv selalu terinisialisasi agar dotenv.env aman diakses tanpa melempar NotInitializedError
  if (!dotenv.isInitialized) {
    dotenv.loadFromString(envString: '');
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabaseAnonKey,
      );
      debugPrint('Supabase berhasil diinisialisasi dari .env: $supabaseUrl');
    } catch (e) {
      debugPrint('Error Supabase.initialize: $e');
    }
  } else {
    debugPrint('PERINGATAN: SUPABASE_URL atau SUPABASE_ANON_KEY tidak ditemukan di .env. Pastikan konfigurasi .env sudah sesuai.');
  }

  // Layanan khusus non-web (notifikasi lokal & permission)
  if (!kIsWeb) {
    try {
      await NotificationService().init();
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  try {
    await CurrencyService.instance.init();
  } catch (e) {
    debugPrint('CurrencyService init error: $e');
  }

  try {
    await ThemeService.instance.init();
  } catch (e) {
    debugPrint('ThemeService init error: $e');
  }

  try {
    await MaintenanceService.instance.init();
  } catch (e) {
    debugPrint('MaintenanceService init error: $e');
  }

  try {
    await SessionService.instance.init();
  } catch (e) {
    debugPrint('SessionService init error: $e');
  }

  try {
    await LanguageService.instance.init();
  } catch (e) {
    debugPrint('LanguageService init error: $e');
  }

  // Meminta izin akses utama (khusus perangkat fisik mobile)
  if (!kIsWeb) {
    try {
      await [
        Permission.locationWhenInUse,
        Permission.camera,
        Permission.photos,
        Permission.notification,
      ].request();
    } catch (e) {
      debugPrint('Gagal meminta izin: $e');
    }

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  runApp(const ParkSmartApp());
}

class ParkSmartApp extends StatelessWidget {
  const ParkSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ThemeService.instance,
        LanguageService.instance,
      ]),
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'SmartPark',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeService.instance.themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown
            },
          ),
          builder: (context, child) {
            return Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => SessionService.instance.recordUserActivity(),
              onPointerMove: (_) => SessionService.instance.recordUserActivity(),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const LoginScreen(),
        );
      },
    );
  }
}
