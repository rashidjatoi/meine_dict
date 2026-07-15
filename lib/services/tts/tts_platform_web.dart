import 'package:web/web.dart' as web;

import 'tts_platform.dart';

class WebTtsPlatform implements TtsPlatform {
  @override
  bool get isAvailable => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> speakGerman(String text) async {
    final synthesis = web.window.speechSynthesis;
    synthesis.cancel();
    final utterance = web.SpeechSynthesisUtterance(text);
    utterance.lang = 'de-DE';
    utterance.rate = 0.85;
    synthesis.speak(utterance);
  }

  @override
  Future<void> stop() async {
    web.window.speechSynthesis.cancel();
  }
}

TtsPlatform createTtsPlatform() => WebTtsPlatform();
