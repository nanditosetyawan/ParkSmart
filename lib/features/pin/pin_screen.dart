import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_screen.dart';
import '../../core/services/notification_service.dart';

class PinScreen extends StatefulWidget {
  final Widget nextScreen;
  final String transactionType; // 'parkir' atau 'perpanjangan parkir'

  const PinScreen({
    super.key,
    required this.nextScreen,
    required this.transactionType,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Request notification permissions when PIN screen is opened
    NotificationService().requestPermissions();
  }

  void _onPinChanged(String value) async {
    if (value.length == 4 && !_isProcessing) {
      setState(() {
        _isProcessing = true;
      });
      // Close keyboard
      FocusScope.of(context).unfocus();

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text('Pembayaran Berhasil', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
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
        body: 'Pembayaran  Anda berhasil.',
      );

      // Wait a moment then navigate
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context); // close dialog
        // Push the next screen and remove previous stack (optional, based on requirement)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => widget.nextScreen));
      }
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C18)),
          onPressed: () {
            // "balik ke home wajib"
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
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
              const Icon(Icons.security, size: 64, color: Color(0xFF1C1D1F)),
              const SizedBox(height: 24),
              Text(
                'Masukkan PIN',
                style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18)),
              ),
              const SizedBox(height: 8),
              Text(
                'Masukkan 4 digit PIN keamanan Anda',
                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF76777B)),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _pinController,
                autofocus: true,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 32, letterSpacing: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: const Color(0xFFE5E2DB).withValues(alpha: 0.8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF1C1D1F), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: _onPinChanged,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
