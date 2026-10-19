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

  // Inisialisasi Supabase Backend
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://necsdylhtswrrqassvzp.supabase.co';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  if (supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      debugPrint('Supabase berhasil diinisialisasi: $supabaseUrl');
    } catch (e) {
      debugPrint('Error Supabase.initialize: $e');
    }
  }

  await NotificationService().init();
  await CurrencyService.instance.init();
  await ThemeService.instance.init();
  await MaintenanceService.instance.init();
  
  // Meminta izin akses utama
  try {
    await [
      Permission.locationWhenInUse,
      Permission.camera,
      Permission.photos,
      Permission.notification,
    ].request();
  } catch (e) {
    debugPrint('Gagal meminta izin: ');
  }

  WidgetsFlutterBinding.ensureInitialized();
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
