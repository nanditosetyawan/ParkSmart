import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/services/theme_service.dart';

// Admin
import 'admin/admin_dashboard_screen.dart';
import 'admin/admin_locations_screen.dart';
import 'admin/admin_slot_management_screen.dart';
import 'admin/admin_active_users_screen.dart';
import 'admin/admin_feedback_screen.dart';
import 'admin/admin_arcade_screen.dart';
import 'admin/admin_pricing_screen.dart';
import 'admin/admin_notifications_screen.dart';
import 'admin/admin_kyc_screen.dart';
import 'admin/admin_wallet_screen.dart';
import 'admin/admin_cities_screen.dart';
import 'admin/admin_user_management_screen.dart';
import 'admin/admin_customer_profiles_screen.dart';
import 'admin/admin_bookings_screen.dart';
import 'admin/admin_transactions_screen.dart';
import 'admin/admin_ai_config_screen.dart';
import 'admin/admin_app_settings_screen.dart';
import 'admin/manage_parking_screen.dart';
import 'admin/manage_users_screen.dart';
import 'admin/revenue_screen.dart';

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
import 'profile/payment_methods_screen.dart';
import 'vehicle/add_vehicle_screen.dart';

// Home & Notification & Parking
import 'home/home_screen.dart';
import 'notification/notification_screen.dart';
import 'parking/parking_detail_screen.dart';
import 'map/explore_map_screen.dart';

// Nav & Game
import 'navigation/ar_navigation_screen.dart';
import 'game/game_lobby_screen.dart';
import 'game/car_game_screen.dart';

class SitemapScreen extends StatelessWidget {
  const SitemapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : Colors.white,
          appBar: AppBar(
            backgroundColor: isDark ? theme.bg : Colors.white,
            elevation: 0,
            title: Text(
              'Developer Sitemap',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          body: ListView(
            children: [
              _buildCategory('Auth', [
                _Item('Login', (c) => const LoginScreen()),
                _Item('Register', (c) => const RegisterScreen()),
                _Item('OTP / Reset', (c) => const OtpResetScreen()),
              ], isDark, theme),
              _buildCategory('Main App', [
                _Item('Home', (c) => const HomeScreen()),
                _Item('Notifications', (c) => const NotificationScreen()),
                _Item('Peta Jelajah (Google Maps)', (c) => const ExploreMapScreen()),
                _Item('Parking Detail', (c) => const ParkingDetailScreen()),
              ], isDark, theme),
              _buildCategory('Booking', [
                _Item('AR Navigation', (c) => const ArNavigationScreen()),
                _Item('Slot Selection', (c) => const SlotSelectionScreen()),
                _Item('Booking Confirmation', (c) => const BookingConfirmationScreen()),
                _Item('Checkout', (c) => const CheckoutScreen()),
              ], isDark, theme),
              _buildCategory('Session', [
                _Item('Check-In', (c) => const CheckinScreen()),
                _Item('Active Session', (c) => const ActiveSessionScreen()),
                _Item('Sesi Berakhir Segera', (c) => const ExpiringSessionScreen()),
                _Item('Extend Session', (c) => const ExtendSessionScreen()),
                _Item('Selesai Parkir (Checkout)', (c) => const SessionCheckoutScreen()),
              ], isDark, theme),
              _buildCategory('History', [
                _Item('Riwayat Parkir Utama', (c) => const HistoryScreen()),
                _Item('Detail Riwayat', (c) => const HistoryDetailScreen()),
                _Item('Sesi Terverifikasi', (c) => const VerifiedParkingSessionsScreen()),
              ], isDark, theme),
              _buildCategory('AI Assistant', [
                _Item('Asisten ParkSmart AI', (c) => const AiAssistantScreen()),
                _Item('Hasil Rekomendasi AI', (c) => const AiResultsScreen()),
              ], isDark, theme),
              _buildCategory('Profile & Settings', [
                _Item('Profil Pengguna', (c) => const ProfileScreen()),
                _Item('Preferensi Aplikasi', (c) => const SettingsScreen()),
                _Item('Kendaraan Terdaftar', (c) => const VehicleScreen()),
                _Item('Tambah Kendaraan', (c) => const AddVehicleScreen()),
                _Item('Metode Pembayaran', (c) => const PaymentMethodsScreen()),
                _Item('Bagaimana Pengalaman Parkir', (c) => const FeedbackScreen()),
              ], isDark, theme),
              _buildCategory('Games & AR', [
                _Item('Game Lobby', (c) => const GameLobbyScreen()),
                _Item('Car Game', (c) => const CarGameScreen()),
              ], isDark, theme),
              _buildCategory('Admin / MCP Screens', [
                _Item('Dashboard', (c) => const DashboardScreen()),
                _Item('Locations', (c) => const LocationsScreen()),
                _Item('Slot Management', (c) => const SlotManagementScreen()),
                _Item('Active Users', (c) => const ActiveUsersScreen()),
                _Item('Arcade & Reward', (c) => const ArcadeAdminScreen()),
                _Item('Feedback', (c) => const FeedbackAdminScreen()),
                _Item('Konfigurasi Tarif', (c) => const PricingScreen()),
                _Item('Verifikasi KTP (KYC)', (c) => const AdminKycScreen()),
                _Item('Injeksi Saldo Dompet', (c) => const AdminWalletScreen()),
                _Item('Master Kota & Wilayah', (c) => const AdminCitiesScreen()),
                _Item('Notifikasi Admin', (c) => const AdminNotificationsScreen()),
                _Item('Kelola Admin (P1)', (c) => const AdminUserManagementScreen()),
                _Item('Profil Customer (P1)', (c) => const AdminCustomerProfilesScreen()),
                _Item('Manajemen Booking (P1)', (c) => const AdminBookingsScreen()),
                _Item('Manajemen Transaksi (P1)', (c) => const AdminTransactionsScreen()),
                _Item('Konfigurasi AI (P2)', (c) => const AdminAiConfigScreen()),
                _Item('Pengaturan App (P2)', (c) => const AdminAppSettingsScreen()),
                _Item('Kelola Parkir (P3)', (c) => const ManageParkingScreen()),
                _Item('Kelola User (P3)', (c) => const ManageUsersScreen()),
                _Item('Pendapatan & Analytics (P3)', (c) => const RevenueScreen()),
              ], isDark, theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategory(String title, List<_Item> items, bool isDark, ThemeService theme) {
    return ExpansionTile(
      collapsedIconColor: isDark ? const Color(0xFF94A3B8) : Colors.black54,
      iconColor: isDark ? Colors.white : Colors.black,
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      children: items.map((i) => Builder(
        builder: (ctx) => ListTile(
          title: Text(
            i.name,
            style: GoogleFonts.plusJakartaSans(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1C1C18),
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
          ),
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
