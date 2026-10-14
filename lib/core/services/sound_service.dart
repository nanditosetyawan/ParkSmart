import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static const MethodChannel _channel = MethodChannel('com.example.smart_parking/audio');

  /// Memutar sound efek saat permainan simulasi mobil dimulai (start.mp3),
  /// yang kemudian secara otomatis dilanjutkan memutar musik in-game secara loop:
  /// - Mode biasa: inGameCar.mp3 (ingamecar.mp3)
  /// - Mode bonus: car_bonusMode.mp3 (car_bonusmode.mp3)
  static Future<void> playStartSound({bool isBonus = false}) async {
    try {
      await _channel.invokeMethod('playStartSound', {'isBonus': isBonus});
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('[SoundService] Info playStartSound: $e');
    }
  }

  /// Memulai suara musik in-game secara manual dalam mode looping.
  static Future<void> startInGameSound({bool isBonus = false}) async {
    try {
      await _channel.invokeMethod('startInGameSound', {'isBonus': isBonus});
    } catch (e) {
      debugPrint('[SoundService] Info startInGameSound: $e');
    }
  }

  /// Menghentikan suara musik in-game (misal saat parkir rapi atau saat dialog muncul).
  static Future<void> stopInGameSound() async {
    try {
      await _channel.invokeMethod('stopInGameSound');
    } catch (e) {
      debugPrint('[SoundService] Info stopInGameSound: $e');
    }
  }

  /// Memutar sound Game Over (die.mp3) baik di mode biasa maupun mode bonus.
  /// Otomatis mematikan musik in-game terlebih dahulu sebelum die.mp3 dibunyikan.
  static Future<void> playGameOverSound() async {
    try {
      await _channel.invokeMethod('playGameOverSound', {'sound': 'die'});
      HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('[SoundService] Info playGameOverSound: $e');
      HapticFeedback.vibrate();
    }
  }

  /// Menghentikan seluruh suara yang aktif saat keluar dari game (dispose).
  static Future<void> stopAllSounds() async {
    try {
      await _channel.invokeMethod('stopAllSounds');
    } catch (e) {
      debugPrint('[SoundService] Info stopAllSounds: $e');
    }
  }
}
