import 'package:flutter/material.dart';
import 'rules_page.dart';
import 'audio_manager.dart';
import 'credits_page.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  late double _musicVolume;
  late double _soundFxVolume;
  final AudioManager _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    _musicVolume = _audioManager.musicVolume;
    _soundFxVolume = _audioManager.soundFxVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 161, 159, 159),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 49, 49, 49),
        centerTitle: true,
        title: const Text(
          'Settings',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'Zubilo',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: textShadows),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait =
              MediaQuery.of(context).orientation == Orientation.portrait;

          return SingleChildScrollView(
            child:
                isPortrait ? _buildPortraitLayout() : _buildLandscapeLayout(),
          );
        },
      ),
    );
  }

  // Portrait layout
  Widget _buildPortraitLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(
              'Enable Notifications',
              style: TextStyle(
                  fontFamily: 'Zubilo',
                  fontSize: 24,
                  color: Colors.white,
                  shadows: textShadows2),
            ),
            value: _notificationsEnabled,
            activeColor: const Color.fromARGB(255, 49, 49, 49),
            inactiveTrackColor: Colors.brown[50],
            inactiveThumbColor: Color.fromARGB(255, 161, 159, 159),
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildVolumeSettings(),
          const SizedBox(height: 30),
          _buildHelpButton(),
          const SizedBox(height: 16),
          _buildCreditsButton(),
        ],
      ),
    );
  }

  // Landscape layout (side-by-side view) wrapped in SingleChildScrollView
  Widget _buildLandscapeLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text(
                    'Enable Notifications',
                    style: TextStyle(
                        fontFamily: 'Zubilo',
                        fontSize: 24,
                        color: Colors.white,
                        shadows: textShadows2),
                  ),
                  value: _notificationsEnabled,
                  activeColor: const Color.fromARGB(255, 49, 49, 49),
                  inactiveTrackColor: Colors.brown[50],
                  inactiveThumbColor: Color.fromARGB(255, 161, 159, 159),
                  onChanged: (bool value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildVolumeSettings(),
              ],
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpButton(),
                const SizedBox(height: 16),
                _buildCreditsButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Volume settings widget (both in portrait and landscape)
  Widget _buildVolumeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Music Volume',
          style: TextStyle(
              fontFamily: 'Zubilo',
              fontSize: 24,
              color: Colors.white,
              shadows: textShadows2),
        ),
        Slider(
          value: _musicVolume,
          onChanged: (double value) {
            setState(() {
              _musicVolume = value;
            });
            _audioManager.setMusicVolume(value);
          },
          min: 0.0,
          max: 1.0,
          activeColor: const Color.fromARGB(255, 49, 49, 49),
          inactiveColor: Colors.white,
        ),
        const SizedBox(height: 16),
        const Text(
          'Sound FX Volume',
          style: TextStyle(
              fontFamily: 'Zubilo',
              fontSize: 24,
              color: Colors.white,
              shadows: textShadows2),
        ),
        Slider(
          value: _soundFxVolume,
          onChanged: (double value) {
            setState(() {
              _soundFxVolume = value;
            });
            _audioManager.setSoundFxVolume(value);
          },
          min: 0.0,
          max: 1.0,
          activeColor: const Color.fromARGB(255, 49, 49, 49),
          inactiveColor: Colors.white,
        ),
      ],
    );
  }

  // Help button widget (both in portrait and landscape)
  Widget _buildHelpButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RulesPage()),
        );
      },
      icon: const Icon(Icons.help_outline, color: Colors.white),
      label: const Text(
        'Help',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontFamily: 'Zubilo', fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 49, 49, 49),
        foregroundColor: Colors.white,
        shadowColor: Colors.black,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  // Credits button widget (both in portrait and landscape)
  Widget _buildCreditsButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreditsPage()),
        );
      },
      icon: const Icon(Icons.star, color: Colors.white),
      label: const Text(
        'Credits',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontFamily: 'Zubilo', fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 49, 49, 49),
        foregroundColor: Colors.white,
        shadowColor: Colors.black,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}

const List<Shadow> textShadows2 = [
  Shadow(offset: Offset(-1, -1), color: Colors.black),
  Shadow(offset: Offset(1, -1), color: Colors.black),
  Shadow(offset: Offset(-1, 1), color: Colors.black),
  Shadow(offset: Offset(1, 1), color: Colors.black),
];
