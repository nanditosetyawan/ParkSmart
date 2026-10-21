import 'dart:math' as math;
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

import '../../core/services/session_service.dart';
import 'edit_profile_screen.dart' as edit_profile;
import 'backend/profile_backend.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    ProfileBackend.instance.fetchProfile();
  }

  Widget _buildMemberBadge(String tier) {
    return _ShimmerMemberBadge(tier: tier);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, ProfileBackend.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final profile = ProfileBackend.instance;
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
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => edit_profile.EditProfileScreen(
                          initialName: profile.name,
                          initialEmail: profile.email,
                          initialPhone: profile.phone,
                        ),
                      ),
                    ),
                    child: Container(
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
                            child: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(profile.avatarUrl!),
                                  )
                                : CircleAvatar(
                                    backgroundColor: const Color(0xFF114177),
                                    child: Text(
                                      profile.name.trim().isNotEmpty ? profile.name.trim()[0].toUpperCase() : 'J',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Text(profile.name, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: ThemeService.instance.textPrimary)),
                          const SizedBox(height: 4),
                          Text('${profile.email}\n${profile.phone}', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: ThemeService.instance.textSecondary, height: 1.5)),
                          const SizedBox(height: 16),
                          _buildMemberBadge(profile.memberTier),
                        ],
                      ),
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
                              Text('${profile.totalParking} Kali', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: ThemeService.instance.textPrimary)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: ThemeService.instance.divider),
                        Expanded(
                          child: Column(
                            children: [
                              Text('PENGHEMATAN', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: ThemeService.instance.textSecondary, letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text(CurrencyService.instance.format(profile.totalSavings), style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFFC05621))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Menu Items
                  _MenuItem(
                    icon: Icons.directions_car, subtitle: 'KENDARAAN TERDAFTAR', title: profile.primaryVehicle,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const vehicle.VehicleScreen())),
                  ),
                  const SizedBox(height: 12),
                  ListenableBuilder(
                    listenable: CurrencyService.instance,
                    builder: (context, _) => _MenuItem(
                      icon: Icons.account_balance_wallet,
                      subtitle: 'METODE PEMBAYARAN',
                      title: 'ParkSmart Pay (${CurrencyService.instance.format(profile.walletBalance)})',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
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
                        SessionService.instance.clearSession();
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
                  SizedBox(height: math.max(MediaQuery.of(context).padding.bottom + 12, 24) + 76),
                ],
              ),
            ),
          ],
        ),
      ),
          // ─── Dark floating dock navigation (fixed bottom with safe area) ────────
          Positioned(
            bottom: math.max(MediaQuery.of(context).padding.bottom + 12, 24),
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

// ─── LENCANA MEMBER DENGAN EFEK KILAU CAHAYA BERGERAK (SEMUA TIER) ───
class _ShimmerMemberBadge extends StatefulWidget {
  final String tier;
  const _ShimmerMemberBadge({required this.tier});

  @override
  State<_ShimmerMemberBadge> createState() => _ShimmerMemberBadgeState();
}

class _ShimmerMemberBadgeState extends State<_ShimmerMemberBadge>
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
    final normTier = widget.tier.trim().toUpperCase();
    final List<Color> gradientColors;
    final Color shadowColor;
    final String label;

    if (normTier == 'BRONZE') {
      label = 'MEMBER BRONZE';
      gradientColors = const [
        Color(0xFF8C532B), // Bronze copper edge
        Color(0xFFBF7B46), // Rich metallic bronze highlight
        Color(0xFF6E3E1C), // Deep bronze shadow
      ];
      shadowColor = const Color(0xFFBF7B46).withValues(alpha: 0.45);
    } else if (normTier == 'SILVER') {
      label = 'MEMBER SILVER';
      gradientColors = const [
        Color(0xFF7E8B9B), // Silver edge
        Color(0xFFBDC7D0), // Lustrous silver center
        Color(0xFF6C7887), // Rich shadow edge
      ];
      shadowColor = const Color(0xFFBDC7D0).withValues(alpha: 0.5);
    } else if (normTier == 'GOLD') {
      label = 'MEMBER GOLD';
      gradientColors = const [
        Color(0xFFC5942B), // Deep rich gold
        Color(0xFFFFD56B), // Brilliant gold highlight
        Color(0xFF9E6E17), // Antique gold shadow
      ];
      shadowColor = const Color(0xFFFFD56B).withValues(alpha: 0.5);
    } else {
      // PLATINUM (default)
      label = 'MEMBER PLATINUM';
      gradientColors = const [
        Color(0xFFA2AAB3), // Platinum darker edge
        Color(0xFFD4D8DD), // Platinum body
        Color(0xFF8B95A1), // Platinum darker edge
      ];
      shadowColor = const Color(0xFFE0E5E9).withValues(alpha: 0.6);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Latar Badge Gradien sesuai Tier
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    label,
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

            // Efek Kilau / Shimmer Cahaya Meluncur dari Kiri ke Kanan
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
