import 'dart:js_interop';
import 'dart:async';

@JS('startSpeechRecognition')
external JSPromise<JSString>? startSpeechRecognition();

Future<String?> startListening() async {
  try {
    final promise = startSpeechRecognition();
    if (promise == null) return null;
    final jsString = await promise.toDart;
    return jsString.toDart;
  } catch (e) {
    return null;
  }
}
