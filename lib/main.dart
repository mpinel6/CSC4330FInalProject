import 'package:flutter/material.dart';
import 'gamevsAI.dart';
import 'matt_home_page.dart';
import 'rules_page.dart';
import 'settings.dart';
import 'lanhome.dart';
import 'aihome.dart';
import 'mattgamecoding.dart';

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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RulesPage()),
      );
    } else if (index == 2) {
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
      backgroundColor: Colors.transparent,
      appBar: isPortrait
          ? AppBar(
              backgroundColor: Colors.brown[700],
              elevation: 4,
              title: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/back.jpg',
            fit: BoxFit.cover,
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return isPortrait
                  ? _buildPortraitLayout()
                  : _buildLandscapeLayout();
            },
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
        selectedItemColor: Colors.brown[700],
        backgroundColor: Colors.brown[200],
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 70),
        const Text(
          'Welcome to',
          style: TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontFamily: 'Zubilo',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(-2, -2),
                color: Colors.black,
                blurRadius: 0,
              ),
              Shadow(
                offset: Offset(2, -2),
                color: Colors.black,
                blurRadius: 0,
              ),
              Shadow(
                offset: Offset(-2, 2),
                color: Colors.black,
                blurRadius: 0,
              ),
              Shadow(
                offset: Offset(2, 2),
                color: Colors.black,
                blurRadius: 0,
              ),
              Shadow(
                offset: Offset(0, -2),
                color: Colors.black,
                blurRadius: 0,
              ),
              Shadow(
                offset: Offset(0, 2),
                color: Colors.black,
                blurRadius: 0,
              ),
              Shadow(
                offset: Offset(-2, 0),
                color: Colors.black,
                blurRadius: 0,
              ),
              Shadow(
                offset: Offset(2, 0),
                color: Colors.black,
                blurRadius: 0,
              ),
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
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 275),
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
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.white,
                    fontFamily: 'Zubilo',
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(-2, -2),
                        color: Colors.black,
                        blurRadius: 0,
                      ),
                      Shadow(
                        offset: Offset(2, -2),
                        color: Colors.black,
                        blurRadius: 0,
                      ),
                      Shadow(
                        offset: Offset(-2, 2),
                        color: Colors.black,
                        blurRadius: 0,
                      ),
                      Shadow(
                        offset: Offset(2, 2),
                        color: Colors.black,
                        blurRadius: 0,
                      ),
                      Shadow(
                        offset: Offset(0, -2),
                        color: Colors.black,
                        blurRadius: 0,
                      ),
                      Shadow(
                        offset: Offset(0, 2),
                        color: Colors.black,
                        blurRadius: 0,
                      ),
                      Shadow(
                        offset: Offset(-2, 0),
                        color: Colors.black,
                        blurRadius: 0,
                      ),
                      Shadow(
                        offset: Offset(2, 0),
                        color: Colors.black,
                        blurRadius: 0,
                      ),
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
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
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
          ),
        ],
      ),
    );
  }

  static Widget buildButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown[700],
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
