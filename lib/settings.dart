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
      backgroundColor: const Color(0xFF6F4E37), // Brownish background
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF3E2723), // Darker brown
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
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Placeholder: Add your functionality
              },
              icon: const Icon(Icons.pause),
              label: const Text(
                'Pause',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700), // Gold-like
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
