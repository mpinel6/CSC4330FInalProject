import 'package:flutter/material.dart';
import 'rules_page.dart';
//import 'Credits_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  double _musicVolume = 0.5;
  double _soundFxVolume = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6F4E37), // Brownish background
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3E2723), // Darker brown
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
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
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Music Volume',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Slider(
                  value: _musicVolume,
                  onChanged: (double value) {
                    setState(() {
                      _musicVolume = value;
                    });
                  },
                  min: 0.0,
                  max: 1.0,
                  activeColor: Colors.amber,
                  inactiveColor: Colors.brown[200],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sound FX Volume',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Slider(
                  value: _soundFxVolume,
                  onChanged: (double value) {
                    setState(() {
                      _soundFxVolume = value;
                    });
                  },
                  min: 0.0,
                  max: 1.0,
                  activeColor: Colors.amber,
                  inactiveColor: Colors.brown[200],
                ),
              ],
            ),
            const SizedBox(height: 30),
           ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RulesPage()),
    );
  },
  icon: const Icon(Icons.help_outline),
  label: const Text(
    'Help',
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
),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
               // Navigator.pushNamed(context, '/credits');
              },
              icon: const Icon(Icons.star),
              label: const Text(
                'Credits',
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
            ),
          ],
        ),
      ),
    );
  }
}
