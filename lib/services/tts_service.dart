import 'tts/tts_platform.dart';
import 'tts/tts_platform_impl.dart' show createTtsPlatform;

class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  final TtsPlatform _platform = createTtsPlatform();
  bool _initialized = false;

  bool get isAvailable => _platform.isAvailable;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _platform.initialize();
    } catch (_) {
      // TTS may be unavailable on some platforms; the app should still run.
    } finally {
      _initialized = true;
    }
  }

  Future<void> speakGerman(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await initialize();
    await _platform.stop();
    await _platform.speakGerman(trimmed);
  }

  Future<void> stop() async {
    await _platform.stop();
  }
}
