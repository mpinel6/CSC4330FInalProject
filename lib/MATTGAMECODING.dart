import 'package:flutter/material.dart';
import 'rules_page.dart';
import 'settings.dart';
import 'matt_home_page.dart';
import 'dart:math';

class mattgamecoding extends StatelessWidget {
  const mattgamecoding({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liars Bar IRL',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MyHomePage(title: 'GAME SCREEN'),
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
  bool _hasDealt = false;
  bool _hasSecondPlayer = false;
  List<Map<String, dynamic>> _selectedCards = [];
  List<Map<String, dynamic>> _player2Cards = [];
  String? _topLeftCard;
  Map<String, bool> _cardSelections = {};
  Map<String, bool> _player2CardSelections = {};
  List<Map<String, dynamic>> _lastPlayedCards = [];
  int _tokens = 3;
  List<String> _deck = [
    'Ace', 'Ace', 'Ace', 'Ace', 'Ace', 'Ace',
    'King', 'King', 'King', 'King', 'King', 'King',
    'Queen', 'Queen', 'Queen', 'Queen', 'Queen', 'Queen',
    'Joker', 'Joker'
  ];

  final List<String> _topCards = [
    'Ace', 'King', 'Queen'
  ];

  void _addSecondPlayer() {
    setState(() {
      _hasSecondPlayer = true;
    });
  }

  void _dealCards() {
    if (_deck.length >= (_hasSecondPlayer ? 10 : 5)) {
      final random = Random();
      _deck.shuffle(random);
      setState(() {
        // Deal cards to first player
        _selectedCards = _deck.take(5).toList().asMap().entries.map((entry) {
          return {
            'id': entry.key,
            'value': entry.value,
          };
        }).toList();
        
        // Deal cards to second player if they exist
        if (_hasSecondPlayer) {
          _player2Cards = _deck.skip(5).take(5).toList().asMap().entries.map((entry) {
            return {
              'id': entry.key + 5, // Offset IDs for second player
              'value': entry.value,
            };
          }).toList();
          _deck.removeRange(0, 10); // Remove both players' cards
        } else {
          _deck.removeRange(0, 5); // Remove only first player's cards
        }
        
        _hasDealt = true;
        // Select a random card for the top left
        _topLeftCard = _topCards[random.nextInt(_topCards.length)];
        // Initialize card selections for both players
        _cardSelections = {for (var card in _selectedCards) '${card['id']}': false};
        _player2CardSelections = {for (var card in _player2Cards) '${card['id']}': false};
      });
    } else {
      // Show a message when there aren't enough cards left
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough cards left in the deck!'),
          backgroundColor: Colors.brown,
        ),
      );
    }
  }

  void _playSelectedCards() {
    setState(() {
      // Store the cards that are about to be played from both players
      _lastPlayedCards = [
        ..._selectedCards.where((card) => _cardSelections['${card['id']}'] == true),
        ..._player2Cards.where((card) => _player2CardSelections['${card['id']}'] == true),
      ];
      
      // Remove selected cards from both players' hands
      _selectedCards.removeWhere((card) => _cardSelections['${card['id']}'] == true);
      _player2Cards.removeWhere((card) => _player2CardSelections['${card['id']}'] == true);
      
      // Clear selections
      _cardSelections.clear();
      _player2CardSelections.clear();
      
      // If no cards left, show message
      if (_selectedCards.isEmpty && _player2Cards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No cards left in hand!'),
            backgroundColor: Colors.brown,
          ),
        );
      }
    });
  }

  void _checkLiar() {
    if (_lastPlayedCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No cards have been played yet!'),
          backgroundColor: Colors.brown,
        ),
      );
      return;
    }

    bool allCardsMatch = _lastPlayedCards.every((card) => card['value'] == _topLeftCard);
    
    // Only decrement tokens if the LIAR should drink (cards don't match)
    if (!allCardsMatch) {
      setState(() {
        _tokens = _tokens > 0 ? _tokens - 1 : 0;
      });
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown[100],
          title: Text(
            allCardsMatch ? 'Accuser Should Drink!' : 'LIAR SHOULD DRINK!',
            style: TextStyle(
              color: Colors.brown[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.brown[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    if (index == 0) { // Home button index
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const matthomepage()),
      );
    } else if (index == 1) { // Rules button index
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RulesPage()),
      );
    } else if (index == 2) { // Settings button index
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
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
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (_hasDealt) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Player 1's hand
                        Column(
                          children: [
                            const Text(
                              'Player 1 Hand:',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ..._selectedCards.map((card) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: _cardSelections['${card['id']}'] ?? false,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _cardSelections['${card['id']}'] = value ?? false;
                                      });
                                    },
                                    activeColor: Colors.brown[700],
                                  ),
                                  Text(
                                    card['value'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ],
                        ),
                        if (_hasSecondPlayer)
                          // Player 2's hand
                          Column(
                            children: [
                              const Text(
                                'Player 2 Hand:',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ..._player2Cards.map((card) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Checkbox(
                                      value: _player2CardSelections['${card['id']}'] ?? false,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _player2CardSelections['${card['id']}'] = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.brown[700],
                                    ),
                                    Text(
                                      card['value'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.brown,
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _playSelectedCards,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                          ),
                          child: const Text(
                            'Play Card(s)',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _checkLiar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                          ),
                          child: const Text(
                            'LIAR!',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (!_hasDealt) ...[
                    ElevatedButton(
                      onPressed: _dealCards,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                      ),
                      child: const Text(
                        'Deal Cards',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    if (!_hasSecondPlayer) ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _addSecondPlayer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[700],
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                        ),
                        child: const Text(
                          'Add Player 2',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          if (_topLeftCard != null)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _topLeftCard!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.stars,
                    color: Colors.brown,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_tokens',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
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
        selectedItemColor: Colors.brown[700],
        backgroundColor: Colors.brown[200],
        onTap: _onItemTapped,
      ),
    );
  }
}
