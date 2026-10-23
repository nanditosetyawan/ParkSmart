import 'package:flutter/material.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/language_service.dart';
import '../session/expiring_session_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'backend/notification_backend.dart';
import '../home/backend/home_backend.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    NotificationBackend.instance.fetchNotifications();
    NotificationBackend.instance.initRealtimeSubscription();
  }

  @override
  void dispose() {
    NotificationBackend.instance.disposeRealtime();
    super.dispose();
  }



  IconData _getIconForType(String? type) {
    switch (type) {
      case 'promo':
        return Icons.local_offer_rounded;
      case 'warning':
      case 'expiry':
        return Icons.access_time_filled;
      case 'success':
      case 'kyc':
        return Icons.check_circle_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case 'promo':
        return const Color(0xFF2A9D8F);
      case 'warning':
      case 'expiry':
        return const Color(0xFFD94B4B);
      case 'success':
      case 'kyc':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF006A9A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, LanguageService.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        final bg = isDark ? theme.bg : const Color(0xFFF6F3EC);
        final cardBg = isDark ? theme.card : Colors.white;
        final cardBorder = isDark ? theme.border : const Color(0xFFE5E2DB);
        final textMain = isDark ? Colors.white : const Color(0xFF1C1C18);
        final textSub = isDark ? theme.textMuted : const Color(0xFF45474A);
        final textHeader = isDark ? theme.textMuted : const Color(0xFFA29F98);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cardBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: cardBorder),
                ),
                child: Icon(Icons.arrow_back, color: textMain, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Notifikasi'.tr,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textMain,
              ),
            ),
            actions: [
              ListenableBuilder(
                listenable: NotificationBackend.instance,
                builder: (context, _) {
                  if (NotificationBackend.instance.unreadCount == 0) return const SizedBox.shrink();
                  return TextButton(
                    onPressed: () => NotificationBackend.instance.markAllAsRead(),
                    child: Text(
                      'Tandai Dibaca'.tr,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => NotificationBackend.instance.fetchNotifications(),
            color: const Color(0xFF10B981),
            child: ListenableBuilder(
              listenable: NotificationBackend.instance,
              builder: (context, _) {
                final notifications = NotificationBackend.instance.notifications;

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Sesi Berakhir Segera hanya tampil jika ada sesi aktif di database
                    if (HomeBackend.instance.activeSession != null)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpiringSessionScreen()));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E232B) : const Color(0xFF1C1C18),
                            borderRadius: BorderRadius.circular(24),
                            border: isDark ? Border.all(color: theme.border) : null,
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black38 : const Color(0xFF1C1C18).withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.timer_outlined, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sesi Berakhir Segera'.tr,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ketuk untuk melihat detail'.tr,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.chevron_right, color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ),

                    Text('Pemberitahuan Sistem (Supabase Live)'.tr, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: textHeader)),
                    const SizedBox(height: 16),

                    if (notifications.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 32,
                                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF114177),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum Ada Notifikasi'.tr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textMain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Pemberitahuan resmi seputar reservasi, timer parkir, dan promo akun Anda akan masuk di sini.'.tr,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: textSub,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Live Supabase cards
                      for (final item in notifications) ...[
                        _buildNotification(
                          icon: _getIconForType(item['notification_type'] as String?),
                          color: _getColorForType(item['notification_type'] as String?),
                          title: (item['title'] as String? ?? 'Pemberitahuan').tr,
                          message: (item['message'] as String? ?? '').tr,
                          isNew: item['is_read'] == false,
                          cardBg: cardBg,
                          cardBorder: cardBorder,
                          textMain: textMain,
                          textSub: textSub,
                          textHeader: textHeader,
                          onTap: () {
                            if (item['id'] != null) {
                              NotificationBackend.instance.markAsRead(item['id'].toString());
                            }
                          },
                        ),
                      ],
                    ],
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotification({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required bool isNew,
    required Color cardBg,
    required Color cardBorder,
    required Color textMain,
    required Color textSub,
    required Color textHeader,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isNew ? color.withValues(alpha: 0.5) : cardBorder,
            width: isNew ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: textMain),
                        ),
                      ),
                      if (isNew)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8, top: 6),
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(message, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: textSub, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
