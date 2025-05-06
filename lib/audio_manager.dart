import 'package:just_audio/just_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  final AudioPlayer _player = AudioPlayer();

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal();

  Future<void> playMusic(String assetPath) async {
    try {
      await _player.setAsset(assetPath);
      _player.setLoopMode(LoopMode.one); // Loops the background music
      _player.play();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  void stopMusic() {
    _player.stop();
  }

  void pauseMusic() {
    _player.pause();
  }

  void resumeMusic() {
    _player.play();
  }
}
