import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static const MethodChannel _channel = MethodChannel('com.example.smart_parking/audio');

  /// Memutar sound efek saat permainan simulasi mobil dimulai (start.mp3),
  /// yang kemudian secara otomatis dilanjutkan memutar inGameCar.mp3 secara berulang (loop).
  static Future<void> playStartSound() async {
    try {
      await _channel.invokeMethod('playStartSound', {'sound': 'start'});
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('[SoundService] Info playStartSound: $e');
    }
  }

  /// Memulai suara mesin mobil inGameCar.mp3 secara manual dalam mode looping.
  static Future<void> startInGameSound() async {
    try {
      await _channel.invokeMethod('startInGameSound', {'sound': 'ingamecar'});
    } catch (e) {
      debugPrint('[SoundService] Info startInGameSound: $e');
    }
  }

  /// Menghentikan suara inGameCar.mp3 (misal saat mobil berhasil parkir atau saat dialog muncul).
  static Future<void> stopInGameSound() async {
    try {
      await _channel.invokeMethod('stopInGameSound');
    } catch (e) {
      debugPrint('[SoundService] Info stopInGameSound: $e');
    }
  }

  /// Memutar sound Game Over saat waktu parkir habis (die.mp3).
  /// Method ini otomatis mematikan inGameCar.mp3 terlebih dahulu sebelum die.mp3 dibunyikan.
  static Future<void> playGameOverSound() async {
    try {
      await _channel.invokeMethod('playGameOverSound', {'sound': 'die'});
      HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('[SoundService] Info playGameOverSound: $e');
      HapticFeedback.vibrate();
    }
  }

  /// Menghentikan seluruh suara yang aktif saat keluar halaman permainan (dispose).
  static Future<void> stopAllSounds() async {
    try {
      await _channel.invokeMethod('stopAllSounds');
    } catch (e) {
      debugPrint('[SoundService] Info stopAllSounds: $e');
    }
  }
}
