import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _fxPlayer = AudioPlayer();

  Future<void> playMusic(String path) async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource(path), volume: _musicVolume);
  }

  Future<void> playFx(String path) async {
    await _fxPlayer.play(AssetSource(path), volume: _fxVolume);
  }

  double _musicVolume = 0.5;
  double _fxVolume = 0.5;

  void setMusicVolume(double volume) {
    _musicVolume = volume;
    _musicPlayer.setVolume(volume);
  }

  void setFxVolume(double volume) {
    _fxVolume = volume;
    // FX volume is used at play time
  }

  double get musicVolume => _musicVolume;
  double get fxVolume => _fxVolume;
}
