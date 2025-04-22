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
      title: 'Jokers Joint',
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
  bool _hasPressedLiar = false; // Track if liar button has been pressed this turn
  List<Map<String, dynamic>> _selectedCards = [];
  List<Map<String, dynamic>> _player2Cards = [];
  String? _topLeftCard;
  Map<String, bool> _cardSelections = {};
  Map<String, bool> _player2CardSelections = {};
  List<Map<String, dynamic>> _lastPlayedCards = [];
  int _player1Tokens = 3;
  int _player2Tokens = 3;
  int _player1LuckyNumber = 0;
  int _player2LuckyNumber = 0;
  List<int> _player1UsedNumbers = [];
  List<int> _player2UsedNumbers = [];
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
        // Reset used numbers when dealing new cards
        _player1UsedNumbers = [];
        _player2UsedNumbers = [];
        // Generate lucky numbers when dealing cards
        _player1LuckyNumber = random.nextInt(6) + 1;
        _player2LuckyNumber = random.nextInt(6) + 1;
        
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
              'id': entry.key + 5,
              'value': entry.value,
            };
          }).toList();
          _deck.removeRange(0, 10);
        } else {
          _deck.removeRange(0, 5);
        }
        
        _hasDealt = true;
        _topLeftCard = _topCards[random.nextInt(_topCards.length)];
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
      _hasPressedLiar = false; // Reset liar button state for new turn
      
      // Check if either player has run out of cards
      if (_selectedCards.isEmpty || _player2Cards.isEmpty) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.brown[100],
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Center(
                child: Text(
                  'Game Complete!',
                  style: TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              content: Center(
                child: Text(
                  _selectedCards.isEmpty ? 'Player 1 has won!' : 'Player 2 has won!',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.brown,
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const matthomepage()),
                        );
                      },
                      child: const Text(
                        'Go Home',
                        style: TextStyle(
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          // Reset game state
                          _hasDealt = false;
                          _hasSecondPlayer = false;
                          _isPlayer1Turn = true;
                          _selectedCards = [];
                          _player2Cards = [];
                          _topLeftCard = null;
                          _cardSelections = {};
                          _player2CardSelections = {};
                          _lastPlayedCards = [];
                          _player1Tokens = 3;
                          _player2Tokens = 3;
                          _player1UsedNumbers = [];
                          _player2UsedNumbers = [];
                          _deck = [
                            'Ace', 'Ace', 'Ace', 'Ace', 'Ace', 'Ace',
                            'King', 'King', 'King', 'King', 'King', 'King',
                            'Queen', 'Queen', 'Queen', 'Queen', 'Queen', 'Queen',
                            'Joker', 'Joker'
                          ];
                        });
                      },
                      child: const Text(
                        'Play Again',
                        style: TextStyle(
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
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

    setState(() {
      _hasPressedLiar = true; // Mark that liar button has been pressed
    });

    // Check if all cards match the top card, treating Jokers as wild cards
    bool allCardsMatch = _lastPlayedCards.every((card) => 
      card['value'] == _topLeftCard || card['value'] == 'Joker'
    );
    
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

    // Function to show Test Your Luck dialog
    void showTestYourLuck(bool isPlayer1) {
      double sliderValue = 1;
      bool hasRolled = false;
      final random = Random();

      // Get available numbers (numbers not yet used) for the specific player
      List<int> availableNumbers = List.generate(6, (index) => index + 1)
          .where((num) => !(isPlayer1 ? _player1UsedNumbers : _player2UsedNumbers).contains(num))
          .toList();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: Colors.brown[100],
                contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: const Center(
                  child: Text(
                    'Test Your Luck!',
                    style: TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isPlayer1 ? 'Player 1, test your luck!' : 'Player 2, test your luck!',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      value: sliderValue,
                      min: 1,
                      max: 6,
                      divisions: 5,
                      label: sliderValue.round().toString(),
                      onChanged: hasRolled ? null : (value) {
                        setDialogState(() {
                          sliderValue = value;
                        });
                      },
                      activeColor: Colors.brown[700],
                    ),
                    Text(
                      '${sliderValue.round()}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Lucky Number: ${isPlayer1 ? _player1LuckyNumber : _player2LuckyNumber}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if ((isPlayer1 ? _player1UsedNumbers : _player2UsedNumbers).isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Used Numbers: ${(isPlayer1 ? _player1UsedNumbers : _player2UsedNumbers).join(", ")}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                      onPressed: hasRolled ? null : () {
                        setDialogState(() {
                          // Only roll from available numbers
                          if (availableNumbers.isNotEmpty) {
                            int randomIndex = random.nextInt(availableNumbers.length);
                            sliderValue = availableNumbers[randomIndex].toDouble();
                            // Add the rolled number to used numbers for the specific player
                            if (isPlayer1) {
                              _player1UsedNumbers.add(sliderValue.round());
                            } else {
                              _player2UsedNumbers.add(sliderValue.round());
                            }
                          }
                          hasRolled = true;
                          
                          // Check if the rolled number matches the player's lucky number
                          if (sliderValue.round() == (isPlayer1 ? _player1LuckyNumber : _player2LuckyNumber)) {
                            setState(() {
                              if (isPlayer1) {
                                _player1Tokens = _player1Tokens > 0 ? _player1Tokens - 1 : 0;
                              } else {
                                _player2Tokens = _player2Tokens > 0 ? _player2Tokens - 1 : 0;
                              }
                            });
                            
                            // Show losing message
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.brown[100],
                                  title: const Text(
                                    'Bad Luck!',
                                    style: TextStyle(
                                      color: Colors.brown,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    isPlayer1 ? 'Player 1 loses a token!' : 'Player 2 loses a token!',
                                    style: const TextStyle(
                                      color: Colors.brown,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the Bad Luck dialog
                                        Navigator.of(context).pop(); // Close the Test Your Luck dialog
                                        setState(() {
                                          // Reset game state
                                          _hasDealt = false;
                                          _hasSecondPlayer = false;
                                          _isPlayer1Turn = true;
                                          _selectedCards = [];
                                          _player2Cards = [];
                                          _topLeftCard = null;
                                          _cardSelections = {};
                                          _player2CardSelections = {};
                                          _lastPlayedCards = [];
                                          _player1Tokens = 3;
                                          _player2Tokens = 3;
                                          _player1UsedNumbers = [];
                                          _player2UsedNumbers = [];
                                          _deck = [
                                            'Ace', 'Ace', 'Ace', 'Ace', 'Ace', 'Ace',
                                            'King', 'King', 'King', 'King', 'King', 'King',
                                            'Queen', 'Queen', 'Queen', 'Queen', 'Queen', 'Queen',
                                            'Joker', 'Joker'
                                          ];
                                        });
                                      },
                                      child: const Text(
                                        'Restart Game',
                                        style: TextStyle(
                                          color: Colors.brown,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text(
                        hasRolled ? 'Rolled!' : 'Roll!',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }
    
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
                // Show Test Your Luck for the player who should drink
                if (allCardsMatch) {
                  showTestYourLuck(_isPlayer1Turn);
                } else {
                  showTestYourLuck(!_isPlayer1Turn);
                }
              },
              child: const Text(
                'Test Your Luck',
                style: TextStyle(
                  color: Colors.brown,
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
                          onPressed: () {
                            // Check if any cards are selected for the current player
                            bool hasSelectedCards = _isPlayer1Turn
                                ? _cardSelections.values.any((selected) => selected)
                                : _player2CardSelections.values.any((selected) => selected);
                            
                            if (hasSelectedCards) {
                              _playSelectedCards();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                          ),
                          child: Text(
                            _isPlayer1Turn
                                ? (_cardSelections.values.any((selected) => selected)
                                    ? 'Play Card(s)'
                                    : 'Select Cards to Play')
                                : (_player2CardSelections.values.any((selected) => selected)
                                    ? 'Play Card(s)'
                                    : 'Select Cards to Play'),
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _hasPressedLiar ? null : _checkLiar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasPressedLiar ? Colors.grey : Colors.red[700],
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                          ),
                          child: Text(
                            _isPlayer1Turn && _lastPlayedCards.isEmpty ? 'No Cards Placed' :
                            _hasPressedLiar ? 'LIAR (Used)' : 'LIAR!',
                            style: const TextStyle(fontSize: 18, color: Colors.white),
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
