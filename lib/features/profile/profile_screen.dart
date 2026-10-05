import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../session/extend_session_screen.dart' as extend;
import '../session/session_checkout_screen.dart' as checkout;
import '../../widgets/bottom_dock_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart' as auth;
import 'vehicle_screen.dart' as vehicle;
import 'settings_screen.dart' as settings;
import 'feedback_screen.dart' as feedback;
import '../history/history_screen.dart' as history;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const BottomDockNavigation(activeTab: DockTab.profile),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: const Color(0xFFE4DFD5).withValues(alpha: 0.3))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Profil Pengguna', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18), letterSpacing: -0.5)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const settings.SettingsScreen()));
                    },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE4DFD5).withValues(alpha: 0.7)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
                      child: const Icon(Icons.settings, size: 20, color: Color(0xFF1A1A18)),
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
                      color: Colors.white, borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE4DFD5).withValues(alpha: 0.6)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 96, height: 96,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: const Color(0xFFF5F1E8), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE4DFD5).withValues(alpha: 0.8))),
                              child: const CircleAvatar(
                                backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBN229OME29oeIA03JEkx6qFXdwAiS9tjF2BpuYl0hvR-KRhMbz_TvFM6WCf8r3FfXONbNsAuRJAFymMuLXfHc9_GTa3l48rS4pmj3LFXkDTJQw34ftZgSowlpEj41hbbTvfBKg3P2JHB5MfmHQNghgDyk3ewQpsqLqxRHecKK3Y9QxSY1Og5axl9wsXmXNuN4ylTP0yU_d0SB-yYJ_riMPPALuIk5G7brwi5Pkb555Yu3zsk6gd9w-'),
                              ),
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(color: const Color(0xFF1A1A18), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                child: const Icon(Icons.edit, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Sarah Pramudita', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                        const SizedBox(height: 4),
                        Text('sarah.pramudita@email.com • +62 812-3456-7890', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF62615B))),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFF2A2723), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD4A359).withValues(alpha: 0.2))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.workspace_premium, size: 16, color: Color(0xFFD4A359)),
                              const SizedBox(width: 6),
                              Text('MEMBER PLATINUM', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD4A359), letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Stats
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F1E8).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE4DFD5).withValues(alpha: 0.7)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text('TOTAL PARKIR', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF62615B), letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text('48 Kali', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: const Color(0xFFE4DFD5).withValues(alpha: 0.6)),
                        Expanded(
                          child: Column(
                            children: [
                              Text('PENGHEMATAN', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF62615B), letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text('Rp 124.000', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF9A442D))),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: const Color(0xFFE4DFD5).withValues(alpha: 0.6)),
                        Expanded(
                          child: Column(
                            children: [
                              Text('PARKSMART PTS', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF62615B), letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text('1.450 Poin', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
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
                  _MenuItem(icon: Icons.account_balance_wallet, subtitle: 'METODE PEMBAYARAN & DOMPET', title: 'ParkSmart Pay (Rp 145.000)', onTap: () {}),
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
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: const Color(0xFFE4DFD5).withValues(alpha: 0.8))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, size: 18, color: Color(0xFF62615B)),
                          const SizedBox(width: 8),
                          Text('KELUAR DARI AKUN', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF62615B), letterSpacing: 1.0)),
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
    );
  }
}


void _showNotificationTestMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 48, height: 4, decoration: BoxDecoration(color: const Color(0xFFE4DFD5), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Text('Test Notifications', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          const SizedBox(height: 16),
          ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFFDE8E8), child: Icon(Icons.timer_off, color: Color(0xFF9B1C1C))),
            title: Text('Urgent Action (10 Min Left)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            subtitle: Text('Simulate overstay warning', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
            onTap: () {
              Navigator.pop(context);
              _showSystemUrgentNotification();
            },
          ),
          ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFE1EFFE), child: Icon(Icons.info_outline, color: Color(0xFF1E429F))),
            title: Text('Info Notification (Success)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            subtitle: Text('Simulate success message', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
            onTap: () {
              Navigator.pop(context);
              _showSystemInfoNotification();
            },
          ),
        ],
      ),
    ),
  );
}


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
bool _notificationsInitialized = false;

Future<void> _initNotifications() async {
  if (_notificationsInitialized) return;
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  
  await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
  
  // Meminta izin notifikasi secara eksplisit (Wajib untuk Android 13+)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
      
  _notificationsInitialized = true;
}

Future<void> _showSystemUrgentNotification() async {
  await _initNotifications();
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'urgent_channel_v2', 'Urgent Notifications',
    channelDescription: 'Peringatan waktu parkir',
    importance: Importance.max,
    priority: Priority.high,
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
  );
}

Future<void> _showSystemInfoNotification() async {
  await _initNotifications();
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

void _showUrgentNotification(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: const Color(0xFF9B1C1C).withValues(alpha: 0.15), blurRadius: 32, offset: const Offset(0, 12))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: const Color(0xFFFDE8E8), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF98080), width: 2)),
              child: const Icon(Icons.timer_off, size: 32, color: Color(0xFFC81E1E)),
            ),
            const SizedBox(height: 16),
            Text('Waktu Parkir Hampir Habis!', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF9B1C1C))),
            const SizedBox(height: 8),
            Text('Sisa waktu parkir Anda tinggal 10 menit. Segera perpanjang sesi atau lakukan checkout untuk menghindari denda overstay sebesar Rp 50.000/jam.', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const extend.ExtendSessionScreen()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC81E1E), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text('Perpanjang', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const checkout.SessionCheckoutScreen()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C1D1F), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text('Checkout', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Abaikan', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B), fontWeight: FontWeight.w600)),
            )
          ],
        ),
      ),
    ),
  );
}

void _showInfoNotification(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE1EFFE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF76A9FA)),
          boxShadow: [BoxShadow(color: const Color(0xFF1E429F).withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF1C64F2)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Pembelian Sukses', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E429F))),
                  Text('Voucher parkir berhasil ditambahkan.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF3F83F8))),
                ],
              ),
            ),
          ],
        ),
      ),
    )
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4DFD5).withValues(alpha: 0.6)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: const Color(0xFFF5F1E8), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, size: 22, color: const Color(0xFF1A1A18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF62615B), letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 20, color: Color(0xFF62615B)),
        ],
      ),
    ),
    );
  }
}
