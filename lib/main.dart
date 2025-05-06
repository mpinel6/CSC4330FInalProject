import 'package:flutter/material.dart';
import 'gamevsAI.dart';
import 'matt_home_page.dart';
import 'rules_page.dart';
import 'settings.dart';
import 'lanhome.dart';
import 'aihome.dart';
import 'mattgamecoding.dart';
import 'audio_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jokers Joint',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Jokers Joint'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _selectedIndex = 0;
  double _logoOpacity = 0.0;

  @override
void initState() {
  super.initState();
  _selectedIndex = 0;
  _logoOpacity = 1.0;

  // Delay audio playback to after the first frame to avoid crashes
  WidgetsBinding.instance.addPostFrameCallback((_) {
    AudioManager().playMusic('assets/sound/BG_Music.mp3');
  });
}

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      if (_selectedIndex != 0) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      setState(() {
        _selectedIndex = 1;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RulesPage()),
      );
    } else if (index == 2) {
      setState(() {
        _selectedIndex = 2;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 161, 159, 159),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return isPortrait
                    ? _buildPortraitLayout()
                    : _buildLandscapeLayout();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Rules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF232323),
        unselectedItemColor: const Color(0xFFB0B0B0),
        backgroundColor: const Color(0xFFD6D6D6),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 60),
          const Text(
            'Welcome to',
            style: TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontFamily: 'Zubilo',
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(offset: Offset(-2, -2), color: Colors.black),
                Shadow(offset: Offset(2, -2), color: Colors.black),
                Shadow(offset: Offset(-2, 2), color: Colors.black),
                Shadow(offset: Offset(2, 2), color: Colors.black),
                Shadow(offset: Offset(0, -2), color: Colors.black),
                Shadow(offset: Offset(0, 2), color: Colors.black),
                Shadow(offset: Offset(-2, 0), color: Colors.black),
                Shadow(offset: Offset(2, 0), color: Colors.black),
                Shadow(offset: Offset(-1, -1), color: Colors.black),
                Shadow(offset: Offset(1, -1), color: Colors.black),
                Shadow(offset: Offset(-1, 1), color: Colors.black),
                Shadow(offset: Offset(1, 1), color: Colors.black),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: _logoOpacity,
            duration: const Duration(seconds: 2),
            child: Image.asset(
              'assets/images/Logo.png',
              width: 350,
              height: 350,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: buildButton('Play LAN', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const lanhome()),
                  );
                }),
              ),
              Flexible(
                child: buildButton('Play AI', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Gamevsai()),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          buildButton('QuickStartTest', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const mattgamecoding()),
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                      fontFamily: 'Zubilo',
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(offset: Offset(-2, -2), color: Colors.black),
                        Shadow(offset: Offset(2, -2), color: Colors.black),
                        Shadow(offset: Offset(-2, 2), color: Colors.black),
                        Shadow(offset: Offset(2, 2), color: Colors.black),
                        Shadow(offset: Offset(0, -2), color: Colors.black),
                        Shadow(offset: Offset(0, 2), color: Colors.black),
                        Shadow(offset: Offset(-2, 0), color: Colors.black),
                        Shadow(offset: Offset(2, 0), color: Colors.black),
                        Shadow(offset: Offset(-1, -1), color: Colors.black),
                        Shadow(offset: Offset(1, -1), color: Colors.black),
                        Shadow(offset: Offset(-1, 1), color: Colors.black),
                        Shadow(offset: Offset(1, 1), color: Colors.black),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 0),
                  AnimatedOpacity(
                    opacity: _logoOpacity,
                    duration: const Duration(seconds: 2),
                    child: Image.asset(
                      'assets/images/Logo.png',
                      width: 230,
                      height: 230,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButton('Play LAN', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const lanhome()),
                    );
                  }),
                  const SizedBox(height: 20),
                  buildButton('Play AI', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Gamevsai()),
                    );
                  }),
                  const SizedBox(height: 20),
                  buildButton('QuickStartTest', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const mattgamecoding()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 49, 49, 49),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 22,
          color: Colors.white,
          fontFamily: 'Zubilo',
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(-1, -1),
              color: Colors.black,
              blurRadius: 0,
            ),
            Shadow(
              offset: Offset(1, -1),
              color: Colors.black,
              blurRadius: 0,
            ),
            Shadow(
              offset: Offset(-1, 1),
              color: Colors.black,
              blurRadius: 0,
            ),
            Shadow(
              offset: Offset(1, 1),
              color: Colors.black,
              blurRadius: 0,
            ),
          ],
        ),
      ),
    );
  }
}

class RulesLayout extends StatelessWidget {
  const RulesLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: RulesContent(key: rulesContentKey),
    );
  }
}
