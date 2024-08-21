import 'package:flutter_tts/flutter_tts.dart';

class SoundService {
  final FlutterTts _tts = FlutterTts();

  Future<void> giveDirection(String direction) async {
    await _tts.speak(direction);
  }
}
