import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/services/notification_service.dart';
import 'core/services/currency_service.dart';
import 'core/services/theme_service.dart';
import 'core/services/maintenance_service.dart';
import 'theme/app_theme.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/login_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Gagal load .env: $e');
  }

  // Inisialisasi Supabase Backend dengan fallback credential valid
  const defaultUrl = 'https://necsdylhtswrrqassvzp.supabase.co';
  const defaultAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5lY3NkeWxodHN3cnJxYXNzdnpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI0MjAxNDIsImV4cCI6MjEwNzk5NjE0Mn0.EZDWK_RFCflWiCzjh-X3bA7B71haE4gLMpiIcyc8qTk';

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? defaultUrl;
  final supabaseAnonKey = (dotenv.env['SUPABASE_ANON_KEY'] != null && dotenv.env['SUPABASE_ANON_KEY']!.isNotEmpty)
      ? dotenv.env['SUPABASE_ANON_KEY']!
      : defaultAnonKey;

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    debugPrint('Supabase berhasil diinisialisasi: $supabaseUrl');
  } catch (e) {
    debugPrint('Error Supabase.initialize: $e');
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
      listenable: ThemeService.instance,
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
          home: const LoginScreen(),
        );
      },
    );
  }
}
