abstract class TtsPlatform {
  bool get isAvailable;

  Future<void> initialize();
  Future<void> speakGerman(String text);
  Future<void> stop();
}
