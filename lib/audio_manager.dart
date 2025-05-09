import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  final AudioPlayer _player = AudioPlayer();
  double _musicVolume = 0.5;
  double _soundFxVolume = 0.5;
  bool _wasPlaying = false;

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal() {
    _loadVolumeSettings();
    _setupLifecycleListener();
  }

  void _setupLifecycleListener() {
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.paused.toString()) {
        // App went to background
        _wasPlaying = _player.playing;
        if (_wasPlaying) {
          await _player.pause();
        }
      } else if (msg == AppLifecycleState.resumed.toString()) {
        // App came to foreground
        if (_wasPlaying) {
          await _player.play();
        }
      }
      return null;
    });
  }

  Future<void> _loadVolumeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
    _soundFxVolume = prefs.getDouble('soundFxVolume') ?? 0.5;
    _player.setVolume(_musicVolume);
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume;
    _player.setVolume(volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('musicVolume', volume);
  }

  Future<void> setSoundFxVolume(double volume) async {
    _soundFxVolume = volume;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('soundFxVolume', volume);
  }

  double get musicVolume => _musicVolume;
  double get soundFxVolume => _soundFxVolume;

  Future<void> playMusic(String assetPath) async {
    try {
      await _player.setAsset(assetPath);
      _player.setLoopMode(LoopMode.one); // Loops the background music
      _player.setVolume(_musicVolume);
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
