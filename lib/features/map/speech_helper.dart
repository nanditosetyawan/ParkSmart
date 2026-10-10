import 'speech_helper_stub.dart'
    if (dart.library.js_interop) 'speech_helper_web.dart';

Future<String?> recordSpeech() => startListening();
