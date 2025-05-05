import 'package:just_audio/just_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();

  factory AudioManager() => _instance;

  late final AudioPlayer _player;
  bool _isInitialized = false;

  AudioManager._internal();

  Future<void> playMusic(String assetPath) async {
    if (!_isInitialized) {
      _player = AudioPlayer();
      _isInitialized = true;
    }

    try {
      await _player.setAsset(assetPath);
      _player.setLoopMode(LoopMode.all);
      _player.play();
    } catch (e) {
      print("Error playing music: $e");
    }
  }

  Future<void> stopMusic() async {
    if (_isInitialized) {
      await _player.stop();
    }
  }
}
