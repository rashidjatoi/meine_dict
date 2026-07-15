import 'package:flutter_tts/flutter_tts.dart';

import 'tts_platform.dart';

class IoTtsPlatform implements TtsPlatform {
  FlutterTts? _tts;
  bool _initialized = false;

  @override
  bool get isAvailable => _initialized && _tts != null;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    _tts = FlutterTts();
    await _tts!.setLanguage('de-DE');
    await _tts!.setSpeechRate(0.45);
    await _tts!.setPitch(1.0);
    await _tts!.awaitSpeakCompletion(true);
    _initialized = true;
  }

  @override
  Future<void> speakGerman(String text) async {
    if (_tts == null) await initialize();
    await _tts!.stop();
    await _tts!.speak(text);
  }

  @override
  Future<void> stop() async {
    if (_tts != null) {
      await _tts!.stop();
    }
  }
}

TtsPlatform createTtsPlatform() => IoTtsPlatform();
