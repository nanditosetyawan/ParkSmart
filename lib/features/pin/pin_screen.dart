import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import '../home/home_screen.dart';
import '../../core/services/notification_service.dart';
import '../checkout/backend/checkout_backend.dart';
import 'backend/pin_backend.dart';

class PinScreen extends StatefulWidget {
  final Widget nextScreen;
  final String transactionType; // 'parkir' atau 'perpanjangan parkir'
  final String? customTitle;
  final bool backToHome;
  final String? bookingId;

  const PinScreen({
    super.key,
    required this.nextScreen,
    required this.transactionType,
    this.customTitle,
    this.backToHome = true,
    this.bookingId,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isProcessing = false;
  late bool _isCreatingPin;
  String? _firstEnteredPin;
  bool _isConfirmingPin = false;

  @override
  void initState() {
    super.initState();
    final isCreateType = widget.transactionType.toLowerCase().contains('buat') ||
        widget.transactionType.toLowerCase().contains('reset');
    _isCreatingPin = isCreateType;
    NotificationService().requestPermissions();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final hasPin = await PinBackend.instance.hasPin();
    if (!mounted) return;
    if (!hasPin && !_isCreatingPin) {
      setState(() {
        _isCreatingPin = true;
      });
    }
  }

  Future<void> _handlePaymentSuccess() async {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;

    if (widget.bookingId != null && widget.bookingId!.isNotEmpty) {
      await CheckoutBackend.instance.markBookingAsPaid(widget.bookingId!);
    }

    if (!mounted) return;

    // Show high-contrast success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDark ? theme.surfaceField : Colors.white,
          elevation: 16,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF34D399).withValues(alpha: 0.15)
                        : const Color(0xFF2E7D32).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF2E7D32),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pembayaran Berhasil',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1C1C18),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Transaksi parkir Anda berhasil diproses dan slot telah diamankan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? theme.textMuted : const Color(0xFF62615B),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? theme.surfaceField : const Color(0xFFF1EEE7),
                    borderRadius: BorderRadius.circular(20),
                    border: isDark ? Border.all(color: theme.border) : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Terverifikasi Sistem',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Trigger Push Notification
    await NotificationService().showNotification(
      id: 100,
      title: 'Pembayaran Berhasil',
      body: 'Pembayaran Anda berhasil.',
    );

    // Wait a moment then navigate
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context); // close dialog
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => widget.nextScreen));
    }
  }

  void _onPinChanged(String value) async {
    if (value.length == 4 && !_isProcessing) {
      setState(() {
        _isProcessing = true;
      });
      _focusNode.unfocus();

      // Kasus 1: Sedang dalam alur Buat PIN Baru
      if (_isCreatingPin) {
        if (!_isConfirmingPin) {
          // Tahap 1: Simpan PIN pertama dan minta input konfirmasi
          setState(() {
            _firstEnteredPin = value;
            _isConfirmingPin = true;
            _isProcessing = false;
          });
          _pinController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Masukkan kembali 4 digit PIN untuk konfirmasi.',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 2),
            ),
          );
          _focusNode.requestFocus();
          return;
        }

        // Tahap 2: Validasi konfirmasi PIN
        if (value != _firstEnteredPin) {
          setState(() {
            _isProcessing = false;
            _firstEnteredPin = null;
            _isConfirmingPin = false;
          });
          _pinController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'PIN konfirmasi tidak cocok. Silakan ulangi pembuatan PIN.',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
          _focusNode.requestFocus();
          return;
        }

        // PIN cocok! Simpan ke Supabase
        final success = await PinBackend.instance.updatePin(value);
        if (!mounted) return;

        setState(() {
          _isProcessing = false;
        });

        if (!success) {
          _firstEnteredPin = null;
          _isConfirmingPin = false;
          _pinController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                PinBackend.instance.errorMessage ?? 'Gagal membuat PIN. Silakan coba lagi.',
                style: GoogleFonts.plusJakartaSans(),
              ),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
          _focusNode.requestFocus();
          return;
        }

        // Jika navigasi dari menu Profile / Setting (atau alur buat/reset PIN)
        final isProfileSetup = widget.transactionType.toLowerCase().contains('buat') ||
            widget.transactionType.toLowerCase().contains('reset');

        if (isProfileSetup) {
          final isReset = widget.transactionType.toLowerCase().contains('reset');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isReset ? 'PIN keamanan berhasil direset!' : 'PIN keamanan berhasil dibuat!',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          await NotificationService().showNotification(
            id: 101,
            title: isReset ? 'PIN Berhasil Direset' : 'PIN Berhasil Disimpan',
            body: 'PIN keamanan Anda telah berhasil diperbarui.',
          );
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted) {
            // Jika ada alur layar pembayaran selanjutnya (misal beli tiket parkir): lanjut ke layar PIN pembayaran
            if (widget.nextScreen is PinScreen) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => widget.nextScreen),
              );
            } else if (widget.backToHome) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            } else {
              Navigator.pop(context);
            }
          }
          return;
        }

        // Jika alur checkout/transaksi parkir tapi awalnya belum punya PIN:
        // Setelah PIN tersimpan ke database, beralih ke mode konfirmasi PIN pembayaran
        setState(() {
          _isCreatingPin = false;
          _isConfirmingPin = false;
          _firstEnteredPin = null;
        });
        _pinController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PIN berhasil dibuat! Silakan masukkan PIN untuk konfirmasi pembayaran tiket.',
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 3),
          ),
        );
        _focusNode.requestFocus();
        return;
      }

      // Kasus 2: Verifikasi PIN untuk transaksi biasa
      final isValid = await PinBackend.instance.verifyPin(value);
      if (!mounted) return;

      if (!isValid) {
        setState(() {
          _isProcessing = false;
        });
        _pinController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              PinBackend.instance.errorMessage ?? 'PIN yang dimasukkan salah. Silakan coba lagi.',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
        _focusNode.requestFocus();
        return;
      }

      await _handlePaymentSuccess();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2),
          appBar: AppBar(
            backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2),
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : const Color(0xFF1C1C18),
              ),
              onPressed: () {
                if (_isConfirmingPin) {
                  setState(() {
                    _isConfirmingPin = false;
                    _firstEnteredPin = null;
                    _pinController.clear();
                  });
                  return;
                }
                if (widget.backToHome) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: isDark ? theme.card : const Color(0xFFEBE8E1),
                      shape: BoxShape.circle,
                      border: isDark ? Border.all(color: const Color(0xFF2DD4BF).withValues(alpha: 0.3)) : null,
                    ),
                    child: Icon(
                      _isCreatingPin
                          ? (_isConfirmingPin ? Icons.lock_outline_rounded : Icons.lock_reset_rounded)
                          : Icons.shield_outlined,
                      size: 38,
                      color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF1C1D1F),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isCreatingPin
                        ? (_isConfirmingPin
                            ? 'Konfirmasi PIN Baru'
                            : (widget.customTitle != null && widget.customTitle!.toLowerCase().contains('buat')
                                ? widget.customTitle!
                                : 'Buat PIN Baru'))
                        : (widget.customTitle ?? 'Masukkan PIN'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1C1C18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isCreatingPin
                        ? (_isConfirmingPin
                            ? 'Masukkan kembali 4 digit PIN Anda untuk konfirmasi'
                            : 'Tentukan 4 digit PIN keamanan baru Anda')
                        : 'Masukkan 4 digit PIN keamanan Anda',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: isDark ? theme.textMuted : const Color(0xFF76777B),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 4-Box PIN Display with distinct, high-contrast dots
                  GestureDetector(
                    onTap: () => _focusNode.requestFocus(),
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            final textLength = _pinController.text.length;
                            final isFilled = textLength > index;
                            final isCurrent = textLength == index;

                            return Container(
                              width: 58,
                              height: 64,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: isDark ? theme.surfaceField : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isCurrent
                                      ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF1C1D1F))
                                      : isFilled
                                          ? (isDark ? Colors.white70 : const Color(0xFF1C1D1F))
                                          : (isDark ? theme.border : const Color(0xFFE5E2DB)),
                                  width: isCurrent ? 2 : 1.5,
                                ),
                                boxShadow: isCurrent
                                    ? [
                                        BoxShadow(
                                          color: (isDark ? const Color(0xFF2DD4BF) : Colors.black).withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: isFilled
                                    ? Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    : (isCurrent
                                        ? Container(
                                            width: 2,
                                            height: 24,
                                            color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF1C1D1F),
                                          )
                                        : null),
                              ),
                            );
                          }),
                        ),
                        // Hidden real TextField to seamlessly receive keyboard inputs
                        Opacity(
                          opacity: 0.0,
                          child: TextField(
                            controller: _pinController,
                            focusNode: _focusNode,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            onChanged: (val) {
                              setState(() {});
                              _onPinChanged(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  if (_isProcessing)
                    const SizedBox(
                      height: 36,
                      width: 36,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  else if (_isCreatingPin)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isCreatingPin = false;
                          _pinController.clear();
                        });
                        _focusNode.requestFocus();
                      },
                      child: Text(
                        'Sudah punya PIN? Masukkan PIN',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                        ),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isCreatingPin = true;
                          _pinController.clear();
                        });
                        _focusNode.requestFocus();
                      },
                      child: Text(
                        'Belum punya atau lupa PIN? Buat PIN Baru',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                        ),
                      ),
                    ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
