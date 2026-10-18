import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../widgets/bottom_dock_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/theme_service.dart';
import '../session/expiring_session_screen.dart';
import '../auth/login_screen.dart' as auth;
import 'vehicle_screen.dart' as vehicle;
import 'payment_methods_screen.dart';
import 'settings_screen.dart' as settings;
import 'feedback_screen.dart' as feedback;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildMemberBadge(String tier) {
    if (tier == 'GOLD') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF9E7719), // Dark gold
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text('MEMBER GOLD', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
          ],
        ),
      );
    } else if (tier == 'SILVER') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF9E9E9E), // Solid dull silver, no gradient, looks worse
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_border, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text('MEMBER SILVER', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
          ],
        ),
      );
    } else if (tier == 'BRONZE') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF6B4423), // Dark, dull bronze/brown
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('MEMBER BRONZE', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
      );
    }

    // Default: PLATINUM dengan animasi kilau dari kiri ke kanan
    return const _PlatinumShimmerBadge();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        return Scaffold(
          backgroundColor: theme.bg,
      body: Stack(
        children: [
          SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: ThemeService.instance.border.withValues(alpha: 0.3))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Profil Pengguna', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: ThemeService.instance.textPrimary, letterSpacing: -0.5)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const settings.SettingsScreen()));
                    },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: ThemeService.instance.card, shape: BoxShape.circle, border: Border.all(color: ThemeService.instance.border.withValues(alpha: 0.7)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
                      child: Icon(Icons.settings, size: 20, color: ThemeService.instance.iconColor),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                children: [
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ThemeService.instance.card, borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: ThemeService.instance.border.withValues(alpha: 0.6)),
                      boxShadow: [BoxShadow(color: ThemeService.instance.isDarkMode ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 96, height: 96,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: ThemeService.instance.chipBg, shape: BoxShape.circle, border: Border.all(color: ThemeService.instance.border.withValues(alpha: 0.8))),
                          child: const CircleAvatar(
                            backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBN229OME29oeIA03JEkx6qFXdwAiS9tjF2BpuYl0hvR-KRhMbz_TvFM6WCf8r3FfXONbNsAuRJAFymMuLXfHc9_GTa3l48rS4pmj3LFXkDTJQw34ftZgSowlpEj41hbbTvfBKg3P2JHB5MfmHQNghgDyk3ewQpsqLqxRHecKK3Y9QxSY1Og5axl9wsXmXNuN4ylTP0yU_d0SB-yYJ_riMPPALuIk5G7brwi5Pkb555Yu3zsk6gd9w-'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Sarah Pramudita', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: ThemeService.instance.textPrimary)),
                        const SizedBox(height: 4),
                        Text('sarah.pramudita@email.com\n+62 812-3456-7890', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: ThemeService.instance.textSecondary, height: 1.5)),
                        const SizedBox(height: 16),
                        _buildMemberBadge('PLATINUM'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Stats
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: ThemeService.instance.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: ThemeService.instance.border.withValues(alpha: 0.7)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text('TOTAL PARKIR', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: ThemeService.instance.textSecondary, letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text('48 Kali', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: ThemeService.instance.textPrimary)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: ThemeService.instance.divider),
                        Expanded(
                          child: Column(
                            children: [
                              Text('PENGHEMATAN', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: ThemeService.instance.textSecondary, letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text('Rp 124.000', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFFC05621))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Menu Items
                  _MenuItem(
                    icon: Icons.directions_car, subtitle: 'KENDARAAN TERDAFTAR', title: 'Toyota Raize (B 1234 XYZ)',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const vehicle.VehicleScreen())),
                  ),
                  const SizedBox(height: 12),
                  ListenableBuilder(
                    listenable: CurrencyService.instance,
                    builder: (context, _) => FutureBuilder<SharedPreferences>(
                      future: SharedPreferences.getInstance(),
                      builder: (context, snapshot) {
                        final balance = snapshot.data?.getInt('user_wallet_balance') ?? 145000;
                        return _MenuItem(
                          icon: Icons.account_balance_wallet,
                          subtitle: 'METODE PEMBAYARAN',
                          title: 'ParkSmart Pay (${CurrencyService.instance.format(balance)})',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  _MenuItem(
                    icon: Icons.contact_support, subtitle: 'CUSTOMER CARE', title: 'Bantuan & Dukungan',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const feedback.FeedbackScreen())),
                  ),
                  const SizedBox(height: 24),
                  

                  _MenuItem(
                    icon: Icons.notifications_active, subtitle: 'DEVELOPER OPTIONS', title: 'Test Notification',
                    onTap: () {
                      _showNotificationTestMenu(context);
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Logout
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const auth.LoginScreen()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0000), // Merah darah tua
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('KELUAR DARI AKUN', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 1.0)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
          // ─── Dark floating dock navigation (fixed bottom) ────────
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Center(
              child: const BottomDockNavigation(activeTab: DockTab.profile),
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}


void _showNotificationTestMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;
        return Container(
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: isDark ? Border(top: BorderSide(color: theme.border)) : null,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? theme.border : const Color(0xFFE4DFD5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Test Notifications',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? theme.surfaceField : const Color(0xFFF9F7F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.border),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.35) : const Color(0xFFFDE8E8),
                    child: Icon(Icons.timer_off, color: isDark ? const Color(0xFFF87171) : const Color(0xFF9B1C1C)),
                  ),
                  title: Text(
                    'Urgent Action (10 Min Left)',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Simulate overstay warning',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: theme.textSecondary,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right, color: theme.textSecondary),
                  onTap: () {
                    Navigator.pop(context);
                    _showSystemUrgentNotification(context);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? theme.surfaceField : const Color(0xFFF9F7F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.border),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.35) : const Color(0xFFE1EFFE),
                    child: Icon(Icons.info_outline, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E429F)),
                  ),
                  title: Text(
                    'Info Notification (Success)',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Simulate success message',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: theme.textSecondary,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right, color: theme.textSecondary),
                  onTap: () {
                    Navigator.pop(context);
                    _showSystemInfoNotification(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    ),
  );
}


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
bool _notificationsInitialized = false;

Future<void> _initNotifications(BuildContext context) async {
  if (_notificationsInitialized) return;
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload == 'expiring_session') {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpiringSessionScreen()));
      }
    },
  );
  
  // Meminta izin notifikasi secara eksplisit (Wajib untuk Android 13+)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
      
  _notificationsInitialized = true;
}

Future<void> _showSystemUrgentNotification(BuildContext context) async {
  await _initNotifications(context);
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'urgent_channel_v4', 'Urgent Notifications',
    channelDescription: 'Peringatan waktu parkir dengan suara darurat penuh',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('sound_darurat'),
    audioAttributesUsage: AudioAttributesUsage.alarm,
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction('perpanjang_id', 'Perpanjang'),
      AndroidNotificationAction('checkout_id', 'Checkout'),
    ],
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    id: 0,
    title: 'Sisa Waktu Parkir 10 Menit!',
    body: 'Waktu hampir habis. Segera perpanjang atau checkout.',
    notificationDetails: platformChannelSpecifics,
    payload: 'expiring_session',
  );
}

Future<void> _showSystemInfoNotification(BuildContext context) async {
  await _initNotifications(context);
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'info_channel_v2', 'Info Notifications',
    channelDescription: 'Informasi umum',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    id: 1,
    title: 'Pembelian Sukses',
    body: 'Voucher parkir berhasil ditambahkan ke dompet.',
    notificationDetails: platformChannelSpecifics,
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String subtitle;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.subtitle, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.card, 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.border.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: theme.isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.02), 
              blurRadius: 12, 
              offset: const Offset(0, 2)
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: theme.chipBg, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, size: 22, color: theme.iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: theme.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ─── LENCANA MEMBER PLATINUM DENGAN EFEK KILAU BERGERAK KIRI KE KANAN ───
class _PlatinumShimmerBadge extends StatefulWidget {
  const _PlatinumShimmerBadge();

  @override
  State<_PlatinumShimmerBadge> createState() => _PlatinumShimmerBadgeState();
}

class _PlatinumShimmerBadgeState extends State<_PlatinumShimmerBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -2.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE0E5E9).withValues(alpha: 0.6),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Latar Asli Platinum dengan tipografi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFA2AAB3), // Platinum darker edge
                    Color(0xFFD4D8DD), // Platinum body
                    Color(0xFF8B95A1), // Platinum darker edge
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'MEMBER PLATINUM',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Efek Kilau / Shimmer Meluncur dari Kiri ke Kanan
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _shimmerAnim,
                builder: (context, _) {
                  final double x = _shimmerAnim.value;
                  return IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(x - 0.6, -0.8),
                          end: Alignment(x + 0.6, 0.8),
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.70),
                            Colors.white.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
