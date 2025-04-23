import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  double _volume = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6F4E37),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF3E2723),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: isPortrait
                ? _buildPortraitLayout()
                : _buildLandscapeLayout(),
          );
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSwitchTile(),
        const SizedBox(height: 20),
        _buildVolumeSlider(),
        const SizedBox(height: 30),
        _buildPauseButton(),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSwitchTile(),
              const SizedBox(height: 20),
              _buildPauseButton(),
            ],
          ),
        ),
        Expanded(
          child: _buildVolumeSlider(),
        ),
      ],
    );
  }

  Widget _buildSwitchTile() {
    return SwitchListTile(
      title: const Text(
        'Enable Notifications',
        style: TextStyle(color: Colors.white),
      ),
      value: _notificationsEnabled,
      activeColor: Colors.amber,
      onChanged: (bool value) {
        setState(() {
          _notificationsEnabled = value;
        });
      },
    );
  }

  Widget _buildVolumeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Adjust Volume',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Slider(
          value: _volume,
          onChanged: (double value) {
            setState(() {
              _volume = value;
            });
          },
          min: 0.0,
          max: 1.0,
          activeColor: Colors.amber,
          inactiveColor: Colors.brown[200],
        ),
      ],
    );
  }

  Widget _buildPauseButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // Add functionality here
      },
      icon: const Icon(Icons.pause),
      label: const Text(
        'Pause',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
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
