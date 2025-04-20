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
  bool _isPlayer1Turn = true; // Track whose turn it is
  List<Map<String, dynamic>> _selectedCards = [];
  List<Map<String, dynamic>> _player2Cards = [];
  String? _topLeftCard;
  Map<String, bool> _cardSelections = {};
  Map<String, bool> _player2CardSelections = {};
  List<Map<String, dynamic>> _lastPlayedCards = [];
  int _player1Tokens = 3;
  int _player2Tokens = 3;
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
      // Only allow playing cards for the current player
      if (_isPlayer1Turn) {
        _lastPlayedCards = _selectedCards.where((card) => _cardSelections['${card['id']}'] == true).toList();
        _selectedCards.removeWhere((card) => _cardSelections['${card['id']}'] == true);
        _cardSelections.clear();
      } else {
        _lastPlayedCards = _player2Cards.where((card) => _player2CardSelections['${card['id']}'] == true).toList();
        _player2Cards.removeWhere((card) => _player2CardSelections['${card['id']}'] == true);
        _player2CardSelections.clear();
      }
      
      // Switch turns after playing cards
      _isPlayer1Turn = !_isPlayer1Turn;
      
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
    
    // Remove tokens based on accusation outcome and who made the accusation
    setState(() {
      if (allCardsMatch) {
        // If cards match (Accuser Should Drink), remove token from the accusing player
        if (_isPlayer1Turn) {
          _player1Tokens = _player1Tokens > 0 ? _player1Tokens - 1 : 0;
        } else {
          _player2Tokens = _player2Tokens > 0 ? _player2Tokens - 1 : 0;
        }
      } else {
        // If cards don't match (LIAR SHOULD DRINK), remove token from the other player
        if (_isPlayer1Turn) {
          _player2Tokens = _player2Tokens > 0 ? _player2Tokens - 1 : 0;
        } else {
          _player1Tokens = _player1Tokens > 0 ? _player1Tokens - 1 : 0;
        }
      }
    });
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String message;
        if (allCardsMatch) {
          // If cards match, the accusing player drinks
          message = _isPlayer1Turn ? 'Player 1 Should Drink!' : 'Player 2 Should Drink!';
        } else {
          // If cards don't match, the other player drinks
          message = _isPlayer1Turn ? 'Player 2 Should Drink!' : 'Player 1 Should Drink!';
        }
        
        return AlertDialog(
          backgroundColor: Colors.brown[100],
          title: Text(
            message,
            style: TextStyle(
              color: Colors.brown[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Switch turns after resolving the LIAR check
                setState(() {
                  _isPlayer1Turn = !_isPlayer1Turn;
                });
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
                    // Turn indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.brown[700],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isPlayer1Turn ? 'Player 1\'s Turn' : 'Player 2\'s Turn',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Player 1's hand
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Player 1 Hand:',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.all(8),
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
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$_player1Tokens',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ..._selectedCards.map((card) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: _cardSelections['${card['id']}'] ?? false,
                                    onChanged: _isPlayer1Turn ? (bool? value) {
                                      setState(() {
                                        _cardSelections['${card['id']}'] = value ?? false;
                                      });
                                    } : null,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Player 2 Hand:',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.all(8),
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
                                          size: 20,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$_player2Tokens',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ..._player2Cards.map((card) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Checkbox(
                                      value: _player2CardSelections['${card['id']}'] ?? false,
                                      onChanged: !_isPlayer1Turn ? (bool? value) {
                                        setState(() {
                                          _player2CardSelections['${card['id']}'] = value ?? false;
                                        });
                                      } : null,
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
                    '$_player1Tokens',
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
