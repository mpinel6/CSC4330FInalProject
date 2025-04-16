import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  double _volume = 0.5; // Placeholder volume value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Volume Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adjust Volume',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Pause Button
            ElevatedButton.icon(
              onPressed: () {
                // Placeholder: No functionality yet
              },
              icon: const Icon(Icons.pause),
              label: const Text('Pause'),
            ),
          ],
        ),
      ),
    );
  }
}
