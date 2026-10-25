import 'package:flutter/services.dart';

/// Formatter otomatis untuk masa berlaku STNK Indonesia dengan format template baku:
/// MM • YY (Bulan • Tahun)
///
/// Fitur:
/// 1. Otomatis menambahkan dot pemisah " • " setelah 2 digit bulan
/// 2. Jika angka bulan pertama adalah 2..9, otomatis diberi prefix "0" (contoh: tekan 5 -> "05 • ")
/// 3. Validasi bulan 01 - 12 (contoh: 15 otomatis dikoreksi ke 12)
/// 4. Maksimal 4 digit angka (2 digit bulan + 2 digit tahun)
/// 5. Backspace handling mulus tanpa stuck di pemisah " • "
class StnkExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldText = oldValue.text;
    final newText = newValue.text;

    // Handle backspace saat kursor berada tepat setelah atau pada pemisah " • "
    if (newText.length < oldText.length) {
      if (oldText.endsWith(' • ') && (newText == oldText.substring(0, oldText.length - 1) || newText == oldText.substring(0, oldText.length - 2))) {
        final digits = oldText.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.length >= 2) {
          final remaining = digits.substring(0, digits.length - 1);
          return TextEditingValue(
            text: remaining,
            selection: TextSelection.collapsed(offset: remaining.length),
          );
        }
      }
    }

    final rawDigits = newText.replaceAll(RegExp(r'[^0-9]'), '');
    if (rawDigits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    String digits = rawDigits;
    // Auto-pad single digit bulan jika angka pertama 2..9 (Feb - Des)
    if (digits.length == 1 && int.parse(digits) >= 2) {
      digits = '0$digits';
    } else if (digits.length >= 2) {
      final mVal = int.tryParse(digits.substring(0, 2)) ?? 1;
      if (mVal > 12) {
        digits = '12${digits.substring(2)}';
      } else if (mVal == 0) {
        digits = '01${digits.substring(2)}';
      }
    }

    // Batasi maksimal 4 digit (MM dan YY)
    final cleanDigits = digits.length > 4 ? digits.substring(0, 4) : digits;

    String formatted = '';
    int selectionIndex = 0;

    if (cleanDigits.length == 1) {
      formatted = cleanDigits;
      selectionIndex = 1;
    } else if (cleanDigits.length == 2) {
      // Jika baru mengetik 2 digit, tambahkan dot pemisah " • "
      if (newText.length < oldText.length && !oldText.endsWith(' • ')) {
        formatted = cleanDigits;
        selectionIndex = 2;
      } else {
        formatted = '$cleanDigits • ';
        selectionIndex = formatted.length;
      }
    } else {
      final mm = cleanDigits.substring(0, 2);
      final yy = cleanDigits.substring(2);
      formatted = '$mm • $yy';
      selectionIndex = formatted.length;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }

  /// Helper untuk memformat string mentah menjadi "MM • YY"
  static String format(String raw, {String fallback = '10 • 28'}) {
    if (raw.trim().isEmpty) return fallback;
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return fallback;

    if (digits.length < 2) {
      return '0$digits • 28';
    }
    final mm = digits.substring(0, 2);
    final mVal = int.tryParse(mm) ?? 10;
    final cleanMm = (mVal < 1 ? '01' : (mVal > 12 ? '12' : mm.padLeft(2, '0')));

    final yy = digits.length >= 4
        ? digits.substring(2, 4)
        : (digits.length == 3 ? '0${digits.substring(2)}' : '28');

    return '$cleanMm • $yy';
  }
}
