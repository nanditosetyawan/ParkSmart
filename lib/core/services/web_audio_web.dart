// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

final Map<String, html.AudioElement> _activeAudios = {};

void playWebAudio(String soundName, {bool loop = false}) {
  try {
    stopWebAudio(soundName);

    // Normalisasi nama (misal: 'saya_akan_lawan' atau 'saya-akan-lawan')
    final cleanName = soundName.replaceAll('-', '_');
    
    // Path aset web: Flutter web bisa meletakkan di 'assets/assets/audio/' atau 'assets/audio/'
    final audio = html.AudioElement('assets/audio/$cleanName.mp3');
    audio.loop = loop;

    audio.play().catchError((e) {
      // Fallback ke path alternatif Flutter web
      try {
        final fallback = html.AudioElement('assets/assets/audio/$cleanName.mp3');
        fallback.loop = loop;
        fallback.play().catchError((_) {});
        _activeAudios[soundName] = fallback;
      } catch (_) {}
    });

    _activeAudios[soundName] = audio;
  } catch (_) {}
}

void stopWebAudio([String? soundName]) {
  try {
    if (soundName != null) {
      _activeAudios[soundName]?.pause();
      _activeAudios[soundName]?.currentTime = 0;
      _activeAudios.remove(soundName);
    } else {
      stopAllWebAudio();
    }
  } catch (_) {}
}

void stopAllWebAudio() {
  try {
    for (final audio in _activeAudios.values) {
      audio.pause();
      audio.currentTime = 0;
    }
    _activeAudios.clear();
  } catch (_) {}
}
