import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'web_audio_stub.dart'
    if (dart.library.html) 'web_audio_web.dart';

class SoundService {
  static const MethodChannel _channel = MethodChannel('com.example.smart_parking/audio');

  /// Memutar sound efek saat permainan simulasi mobil dimulai (start.mp3),
  /// yang kemudian secara otomatis dilanjutkan memutar musik in-game secara loop:
  /// - Mode biasa: inGameCar.mp3 (ingamecar.mp3)
  /// - Mode bonus: car_bonusMode.mp3 (car_bonusmode.mp3)
  static Future<void> playStartSound({bool isBonus = false}) async {
    if (kIsWeb) {
      playWebAudio(isBonus ? 'car_bonusmode' : 'ingamecar', loop: true);
      return;
    }
    try {
      await _channel.invokeMethod('playStartSound', {'isBonus': isBonus});
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('[SoundService] Info playStartSound: $e');
    }
  }

  /// Memulai suara musik in-game secara manual dalam mode looping.
  static Future<void> startInGameSound({bool isBonus = false}) async {
    if (kIsWeb) {
      playWebAudio(isBonus ? 'car_bonusmode' : 'ingamecar', loop: true);
      return;
    }
    try {
      await _channel.invokeMethod('startInGameSound', {'isBonus': isBonus});
    } catch (e) {
      debugPrint('[SoundService] Info startInGameSound: $e');
    }
  }

  /// Menghentikan suara musik in-game (misal saat parkir rapi atau saat dialog muncul).
  static Future<void> stopInGameSound() async {
    if (kIsWeb) {
      stopWebAudio('car_bonusmode');
      stopWebAudio('ingamecar');
      return;
    }
    try {
      await _channel.invokeMethod('stopInGameSound');
    } catch (e) {
      debugPrint('[SoundService] Info stopInGameSound: $e');
    }
  }

  /// Memutar sound Game Over (die.mp3) baik di mode biasa maupun mode bonus.
  /// Otomatis mematikan musik in-game terlebih dahulu sebelum die.mp3 dibunyikan.
  static Future<void> playGameOverSound() async {
    if (kIsWeb) {
      stopInGameSound();
      playWebAudio('die', loop: false);
      return;
    }
    try {
      await _channel.invokeMethod('playGameOverSound', {'sound': 'die'});
      HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('[SoundService] Info playGameOverSound: $e');
      HapticFeedback.vibrate();
    }
  }

  /// Memutar musik latar mesin capit (musiccrawls.mp3) secara looping tanpa batas (unlimited)
  /// selama pemain membuka dan berada di halaman game claws_car.
  static Future<void> startClawsMusic() async {
    if (kIsWeb) {
      playWebAudio('musiccrawls', loop: true);
      return;
    }
    try {
      await _channel.invokeMethod('startClawsMusic');
    } catch (e) {
      debugPrint('[SoundService] Info startClawsMusic: $e');
    }
  }

  /// Menghentikan musik latar mesin capit claws_car (misal saat user keluar atau berpindah halaman).
  static Future<void> stopClawsMusic() async {
    if (kIsWeb) {
      stopWebAudio('musiccrawls');
      return;
    }
    try {
      await _channel.invokeMethod('stopClawsMusic');
    } catch (e) {
      debugPrint('[SoundService] Info stopClawsMusic: $e');
    }
  }

  /// Menghentikan seluruh suara yang aktif saat keluar dari game (dispose).
  static Future<void> stopAllSounds() async {
    if (kIsWeb) {
      stopAllWebAudio();
      return;
    }
    try {
      await _channel.invokeMethod('stopAllSounds');
    } catch (e) {
      debugPrint('[SoundService] Info stopAllSounds: $e');
    }
  }

  /// Memutar file suara raw native (res/raw) seperti 'saya_akan_lawan' 1x saat animasi splash screen berjalan.
  static Future<void> playRawSound(String soundName) async {
    if (kIsWeb) {
      playWebAudio(soundName, loop: false);
      return;
    }
    try {
      await _channel.invokeMethod('playRawSound', {'sound': soundName});
    } catch (e) {
      debugPrint('[SoundService] Info playRawSound ($soundName): $e');
    }
  }

  /// Menghentikan pemutaran suara raw jika masih berjalan (misal saat splash screen selesai/dilewati).
  static Future<void> stopRawSound() async {
    if (kIsWeb) {
      stopAllWebAudio();
      return;
    }
    try {
      await _channel.invokeMethod('stopRawSound');
    } catch (e) {
      debugPrint('[SoundService] Info stopRawSound: $e');
    }
  }
}
