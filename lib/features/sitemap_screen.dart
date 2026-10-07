import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Admin
import 'admin/admin_dashboard_screen.dart';
import 'admin/admin_locations_screen.dart';
import 'admin/admin_slot_management_screen.dart';
import 'admin/admin_active_users_screen.dart';
import 'admin/admin_feedback_screen.dart';
import 'admin/admin_arcade_screen.dart';
import 'admin/admin_pricing_screen.dart';

// AI Assistant
import 'ai_assistant/ai_assistant_screen.dart';
import 'ai_assistant/ai_results_screen.dart';

// Auth
import 'auth/login_screen.dart';
import 'auth/otp_reset_screen.dart';
import 'auth/register_screen.dart';

// Booking
import 'booking/booking_confirmation_screen.dart';
import 'booking/slot_selection_screen.dart';

// Checkout & Session
import 'checkout/checkout_screen.dart';
import 'session/active_session_screen.dart';
import 'session/checkin_screen.dart';
import 'session/expiring_session_screen.dart';
import 'session/extend_session_screen.dart';
import 'session/session_checkout_screen.dart';

// History
import 'history/history_detail_screen.dart';
import 'history/history_screen.dart';
import 'history/verified_parking_sessions_screen.dart';

// Profile & Vehicle
import 'profile/feedback_screen.dart';
import 'profile/profile_screen.dart';
import 'profile/settings_screen.dart';
import 'profile/vehicle_screen.dart';
import 'vehicle/add_vehicle_screen.dart';

// Home & Notification & Parking
import 'home/home_screen.dart';
import 'notification/notification_screen.dart';
import 'parking/parking_detail_screen.dart';

// Nav & Game
import 'navigation/ar_navigation_screen.dart';
import 'game/game_lobby_screen.dart';
import 'game/mini_game_screen.dart';

class SitemapScreen extends StatelessWidget {
  const SitemapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Developer Sitemap')),
      body: ListView(
        children: [
          _buildCategory('Auth, otp belom aman', [
            _Item('Login', (c) => const LoginScreen()),
            _Item('Register', (c) => const RegisterScreen()),
            _Item('OTP / Reset', (c) => const OtpResetScreen()),
          ]),
          _buildCategory('Main App, notifikasi belom aman', [
            _Item('Home', (c) => const HomeScreen()),
            _Item('Notifications', (c) => const NotificationScreen()),
            _Item('Parking Detail', (c) => const ParkingDetailScreen()),
          ]),
          _buildCategory('Booking', [
            _Item('Slot Selection', (c) => const SlotSelectionScreen()),
            _Item('Booking Confirmation', (c) => const BookingConfirmationScreen()),
            _Item('Checkout', (c) => const CheckoutScreen()),
          ]),
          _buildCategory('Session, cek notifikasi sesi berakhir segera', [
            _Item('Check-In', (c) => const CheckinScreen()),
            _Item('Active Session', (c) => const ActiveSessionScreen()),
            _Item('Sesi Berakhir Segera', (c) => const ExpiringSessionScreen()),
            _Item('Extend Session', (c) => const ExtendSessionScreen()),
            _Item('Selesai Parkir (Checkout)', (c) => const SessionCheckoutScreen()),
          ]),
          _buildCategory('History', [
            _Item('Riwayat Parkir Utama', (c) => const HistoryScreen()),
            _Item('Detail Riwayat', (c) => const HistoryDetailScreen()),
            _Item('Sesi Terverifikasi', (c) => const VerifiedParkingSessionsScreen()),
          ]),
          _buildCategory('AI Assistant', [
            _Item('Asisten ParkSmart AI', (c) => const AiAssistantScreen()),
            _Item('Hasil Rekomendasi AI', (c) => const AiResultsScreen()),
          ]),
          _buildCategory('Profile & Settings', [
            _Item('Profil Pengguna', (c) => const ProfileScreen()),
            _Item('Preferensi Aplikasi', (c) => const SettingsScreen()),
            _Item('Kendaraan Terdaftar', (c) => const VehicleScreen()),
            _Item('Tambah Kendaraan', (c) => const AddVehicleScreen()),
            _Item('Bagaimana Pengalaman Parkir', (c) => const FeedbackScreen()),
          ]),
          _buildCategory('Games & AR', [
            _Item('AR Navigation', (c) => const ArNavigationScreen()),
            _Item('Game Lobby', (c) => const GameLobbyScreen()),
            _Item('Mini Game', (c) => const MiniGameScreen()),
          ]),
          _buildCategory('Admin / MCP Screens', [
            _Item('Dashboard', (c) => const DashboardScreen()),
            _Item('Locations', (c) => const LocationsScreen()),
            _Item('Slot Management', (c) => const SlotManagementScreen()),
            _Item('Active Users', (c) => const ActiveUsersScreen()),
            _Item('Arcade & Reward', (c) => const ArcadeAdminScreen()),
            _Item('Feedback', (c) => const FeedbackAdminScreen()),
            _Item('Konfigurasi Tarif', (c) => const PricingScreen()),
          ]),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, List<_Item> items) {
    return ExpansionTile(
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
      children: items.map((i) => Builder(
        builder: (ctx) => ListTile(
          title: Text(i.name),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {
            Navigator.push(ctx, MaterialPageRoute(builder: (context) => i.builder(context)));
          },
        ),
      )).toList(),
    );
  }
}

class _Item {
  final String name;
  final Widget Function(BuildContext) builder;
  _Item(this.name, this.builder);
}
