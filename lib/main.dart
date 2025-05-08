import 'package:flutter/material.dart';
import 'gamevsAI.dart';
import 'matt_home_page.dart';
import 'rules_page.dart';
import 'settings.dart';
import 'lanhome.dart';
import 'aihome.dart';
import 'mattgamecoding.dart';
import 'audio_manager.dart';
import 'create_game_ui.dart';
import 'join_game_ui.dart';

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
  int _selectedIndex = 0;
  double _logoOpacity = 1.0;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    if (_isFirstLoad) {
      AudioManager().playMusic('assets/sound/BG_Music.mp3');
      _isFirstLoad = false;
    }
  }

  @override
  void dispose() {
    AudioManager().stopMusic();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Pages to show based on tab selection
  late final List<Widget> _pages = [
    _buildHomeContent(),
    const RulesPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 161, 159, 159),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/Beer.png', width: 35, height: 35),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/Question.png',
                width: 35, height: 35),
            label: 'Rules',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/Settings.png',
                width: 35, height: 35),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF232323),
        unselectedItemColor: const Color(0xFFB0B0B0),
        backgroundColor: const Color(0xFFD6D6D6),
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Zubilo',
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Zubilo',
          fontSize: 14,
        ),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPortrait =
            MediaQuery.of(context).orientation == Orientation.portrait;
        return isPortrait ? _buildPortraitLayout() : _buildLandscapeLayout();
      },
    );
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 100),
          const Text(
            'Welcome to',
            style: TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontFamily: 'Zubilo',
              fontWeight: FontWeight.bold,
              shadows: textShadows,
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
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(child: _buildButton('Play LAN', _showLanTestOptions)),
              Flexible(
                  child: _buildButton('Play AI', () {
                AudioManager().stopMusic();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Gamevsai()));
              })),
            ],
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                      fontFamily: 'Zubilo',
                      fontWeight: FontWeight.bold,
                      shadows: textShadows,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                children: [
                  const SizedBox(height: 60),
                  _buildButton('Play LAN', _showLanTestOptions),
                  const SizedBox(height: 20),
                  _buildButton('Play AI', () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Gamevsai()),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
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
          shadows: textShadows,
        ),
      ),
    );
  }

  void _showLanTestOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown[50],
          title: const Text(
            'Multiplayer Options',
            style: TextStyle(
              fontFamily: 'Zubilo',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: textShadows,
            ),
          ),
          content: const Text('Choose a role:',
              style: TextStyle(
                fontFamily: "Zubilo",
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              )),
          actions: <Widget>[
            TextButton(
              child: const Text('HOST GAME',
                  style: TextStyle(
                      fontFamily: "Zubilo",
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                AudioManager().stopMusic();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateGamePage()),
                );
              },
            ),
            TextButton(
              child: const Text('JOIN GAME',
                  style: TextStyle(
                      fontFamily: "Zubilo",
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                AudioManager().stopMusic();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JoinGamePage()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// Shared shadow style
const List<Shadow> textShadows = [
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
];
