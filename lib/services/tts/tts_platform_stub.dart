import 'tts_platform.dart';

class StubTtsPlatform implements TtsPlatform {
  @override
  bool get isAvailable => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> speakGerman(String text) async {
    throw UnsupportedError('Text-to-speech is not available on this platform.');
  }

  @override
  Future<void> stop() async {}
}

TtsPlatform createTtsPlatform() => StubTtsPlatform();
