import 'package:flutter/material.dart';
import 'rules_page.dart';
import 'settings.dart';
import 'matt_home_page.dart';
import 'dart:math';
import 'main.dart';

class Gamevsai extends StatelessWidget {
  const Gamevsai({super.key});

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
  bool _hasSecondPlayer = true;
  bool _isPlayer1Turn = true;
  bool _hasPressedLiar = false;
  bool _isNavBarVisible = true;
  List<Map<String, dynamic>> _selectedCards = [];
  List<Map<String, dynamic>> _player2Cards = [];
  String?
      _topLeftCard; //this is the card used that the game should be played off of
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
    'Ace',
    'Ace',
    'Ace',
    'Ace',
    'Ace',
    'Ace',
    'King',
    'King',
    'King',
    'King',
    'King',
    'King',
    'Queen',
    'Queen',
    'Queen',
    'Queen',
    'Queen',
    'Queen',
    'Joker',
    'Joker'
  ];

  final List<String> _topCards = ['Ace', 'King', 'Queen'];

  void _addSecondPlayer() {
    setState(() {
      _hasSecondPlayer = true;
    });
  }

  void _dealCards() {
    int requiredLength = 5; //one player 5 cards
    if (_hasSecondPlayer) {
      requiredLength = 10; //2 players 10
    }
    if (_deck.length >= requiredLength) {
      final random = Random();
      _deck.shuffle(random);
      setState(() {
        // the rng mechanic for the roulette
        _player1UsedNumbers = [];
        _player2UsedNumbers = [];
        // each player has a random number that is defined at dealing that will be the reason they lose - token taken out
        _player1LuckyNumber = random.nextInt(6) + 1;
        _player2LuckyNumber = random.nextInt(6) + 1;

        // send out cards
        _selectedCards = _deck.take(5).toList().asMap().entries.map((entry) {
          return {
            'id': entry.key,
            'value': entry.value,
          };
        }).toList();

        // send out cards to second player
        if (_hasSecondPlayer) {
          _player2Cards =
              _deck.skip(5).take(5).toList().asMap().entries.map((entry) {
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
        _cardSelections = {
          for (var card in _selectedCards) '${card['id']}': false
        };
        _player2CardSelections = {
          for (var card in _player2Cards) '${card['id']}': false
        };
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('error'),
          backgroundColor: Colors.brown,
        ),
      );
    }
  }

// here we handle the turn for the cpu - either takes 1 or 2 and will either call liar or play a card based on which rng number given
  void _cpuTurn() {
    if (_player2Cards.isNotEmpty) {
      final randomMove = Random();
      int moveChoice = randomMove.nextInt(2) + 1;
      var playCard = _player2Cards.first;

      if (moveChoice == 2) {
        setState(() {
          _lastPlayedCards = [playCard];
          _player2Cards.removeAt(0);
          _player2CardSelections.clear();
          _isPlayer1Turn = true;
        });
      } else {
        _checkLiar();
        setState(() {
          _lastPlayedCards = [playCard];
          _player2Cards.removeAt(0);
          _player2CardSelections.clear();
          _isPlayer1Turn = true;
        });
      }
    }
  }

  void _playSelectedCards() {
    setState(() {
      // only persons who turn can play cards
      if (_isPlayer1Turn) {
        _lastPlayedCards = _selectedCards
            .where((card) => _cardSelections['${card['id']}'] == true)
            .toList();
        _selectedCards
            .removeWhere((card) => _cardSelections['${card['id']}'] == true);
        _cardSelections.clear();
      }
      // switch to cpu control and add a second delay so its not instant
      _isPlayer1Turn = false;
      if (!_isPlayer1Turn && _hasSecondPlayer) {
        Future.delayed(const Duration(seconds: 1), _cpuTurn);
      }
// Reset liar button
      _hasPressedLiar = false;
      String displayWinner;
      if (_selectedCards.isEmpty) {
        displayWinner = "Player 1 wins";
      } else {
        displayWinner = "Player 2 wins";
      }

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
                  displayWinner,
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
                          MaterialPageRoute(
                              builder: (context) => const MyApp()),
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
                          _hasSecondPlayer = true;
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
                            'Ace',
                            'Ace',
                            'Ace',
                            'Ace',
                            'Ace',
                            'Ace',
                            'King',
                            'King',
                            'King',
                            'King',
                            'King',
                            'King',
                            'Queen',
                            'Queen',
                            'Queen',
                            'Queen',
                            'Queen',
                            'Queen',
                            'Joker',
                            'Joker'
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

// liar button, checks to see if cards match and makes sure someone has actually played a card
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
      //can only press liar button once
      _hasPressedLiar = true;
    });

    // Check if all cards match the top card or is a joker
    bool allCardsMatch = _lastPlayedCards.every(
        (card) => card['value'] == _topLeftCard || card['value'] == 'Joker');
    String message = '';
    // token removal
    setState(() {
      if (allCardsMatch) {
        if (_isPlayer1Turn) {
          if (_player1Tokens > 0) {
            _player1Tokens -= 1;
            message = 'Player 1 loses a token';
          }
        } else {
          if (_player2Tokens > 0) {
            _player2Tokens -= 1;
            message = 'Player 2 loses a token';
          }
        }
      } else {
        // If cards don't match  remove token from the other player
        if (_isPlayer1Turn) {
          if (_player2Tokens > 0) {
            _player2Tokens -= 1;
            message = 'Player 2 loses a token';
          }
        } else {
          if (_player1Tokens > 0) {
            _player1Tokens -= 1;
            message = 'Player 1 loses a token';
          }
        }
      }

      // Check for win condition after token removal
      if (_player2Tokens == 0) {
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
              content: const Center(
                child: Text(
                  'Player 1 wins!',
                  style: TextStyle(
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
                          MaterialPageRoute(
                              builder: (context) => const MyApp()),
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
                          _hasSecondPlayer = true;
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
                            'Ace',
                            'Ace',
                            'Ace',
                            'Ace',
                            'Ace',
                            'Ace',
                            'King',
                            'King',
                            'King',
                            'King',
                            'King',
                            'King',
                            'Queen',
                            'Queen',
                            'Queen',
                            'Queen',
                            'Queen',
                            'Queen',
                            'Joker',
                            'Joker'
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                // taken out roulette game
                if (allCardsMatch) {
                } else {}
              },
              child: const Text(
                'Return To Game',
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

    if (index == 0) {
      // Home button index
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    } else if (index == 1) {
      // Rules button index
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RulesPage()),
      );
    } else if (index == 2) {
      // Settings button index
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String liarbutton;
    if (_lastPlayedCards.isEmpty && _isPlayer1Turn) {
      liarbutton = "No Cards Placed";
    } else if (_hasPressedLiar) {
      liarbutton = "Liar(USED)";
    } else {
      liarbutton = "LIAR";
    }

    String pButtonText;
    if (_isPlayer1Turn) {
      if (_cardSelections.values.any((selected) => selected)) {
        pButtonText = 'Play Card(s)';
      } else {
        pButtonText = 'Select Cards to Play';
      }
    } else {
      if (_player2CardSelections.values.any((selected) => selected)) {
        pButtonText = 'Play Card(s)';
      } else {
        pButtonText = 'Select Cards to Play';
      }
    }
    String displayTurn;
    if (_isPlayer1Turn) {
      displayTurn = 'Player 1\'s Turn';
    } else {
      displayTurn = 'Player 2\'s Turn';
    }

    return Scaffold(
      backgroundColor: Colors.brown[100],
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgroundimage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Table and middle sprite - Fixed position
            Positioned.fill(
              child: Stack(
                children: [
                  // Table
                  Positioned(
                    bottom: -MediaQuery.of(context).size.height * 1,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/images/tableasset.png',
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width * 1.4,
                      height: MediaQuery.of(context).size.height * 1.2,
                    ),
                  ),
                  // Middle sprite
                  Positioned(
                    top: MediaQuery.of(context).size.height *
                        0.1, // Add top offset
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/images/middlesprite.png',
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.7,
                    ),
                  ),
                ],
              ),
            ),
            // Game UI elements
            Column(
              children: [
                // Top section with hamburger and token
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_hasDealt && _topLeftCard != null)
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
                              Image.asset(
                                'assets/images/${_topLeftCard!.toLowerCase()}.jpg',
                                width: 40,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Play: $_topLeftCard',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_hasDealt)
                            Text(
                              displayTurn,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                          const SizedBox(width: 20),
                          if (_hasDealt)
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
                          const SizedBox(width: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.brown[700],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isNavBarVisible ? Icons.menu : Icons.menu_open,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isNavBarVisible = !_isNavBarVisible;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Main game content
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (_hasDealt) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_hasSecondPlayer)
                                  // Player 2's hand
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.brown
                                                      .withOpacity(0.3),
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
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: _isPlayer1Turn
                                      ? () {
                                          bool hasSelectedCards = _isPlayer1Turn
                                              ? _cardSelections.values
                                                  .any((selected) => selected)
                                              : _player2CardSelections.values
                                                  .any((selected) => selected);

                                          if (hasSelectedCards) {
                                            _playSelectedCards();
                                          }
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown[700],
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 6,
                                  ),
                                  child: Text(
                                    pButtonText,
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 6,
                              ),
                              child: const Text(
                                'Deal Cards',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                            if (!_hasSecondPlayer) ...[
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _addSecondPlayer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown[700],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 6,
                                ),
                                child: const Text(
                                  'Add Player 2',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Card hand display
                if (_hasDealt)
                  Container(
                    height: 160,
                    width: MediaQuery.of(context).size.width - 40,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Align(
                      alignment: Alignment.center,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: _isPlayer1Turn
                            ? _selectedCards.length
                            : _player2Cards.length,
                        itemBuilder: (context, index) {
                          final cards =
                              _isPlayer1Turn ? _selectedCards : _player2Cards;
                          final card = cards[index];
                          final isSelected = _isPlayer1Turn
                              ? _cardSelections['${card['id']}'] ?? false
                              : _player2CardSelections['${card['id']}'] ??
                                  false;

                          // Calculate rotation angle based on position
                          final totalCards = cards.length;
                          final maxRotation =
                              0.2; // Maximum rotation in radians
                          final rotationStep = totalCards > 1
                              ? (maxRotation * 2) / (totalCards - 1)
                              : 0.0;
                          final rotation = totalCards > 1
                              ? -maxRotation + (rotationStep * index)
                              : 0.0;

                          // Calculate vertical offset for curved effect
                          final centerIndex = (totalCards - 1) / 2;
                          final verticalOffset = totalCards > 1
                              ? 10.0 *
                                  (index - centerIndex)
                                      .abs() // middle cards are lower
                              : 0.0;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_isPlayer1Turn) {
                                  _cardSelections['${card['id']}'] =
                                      !isSelected;
                                } else {
                                  _player2CardSelections['${card['id']}'] =
                                      !isSelected;
                                }
                              });
                            },
                            child: Transform.translate(
                              offset: Offset(0, verticalOffset),
                              child: Transform.rotate(
                                angle: rotation,
                                child: Container(
                                  width: 80, // slightly smaller width
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 2), // small positive margin
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Image.asset(
                                          'assets/images/${card['value'].toLowerCase()}.jpg',
                                          width: 80,
                                          height: 120,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.brown.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
            // Liar button at bottom right
            if (_hasDealt)
              Positioned(
                bottom: 20,
                right: 20,
                child: ElevatedButton(
                  onPressed:
                      (!_isPlayer1Turn || _hasPressedLiar) ? null : _checkLiar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _hasPressedLiar ? Colors.grey : Colors.red[700],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                  child: Text(
                    liarbutton,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _isNavBarVisible ? kBottomNavigationBarHeight : 0,
        child: SingleChildScrollView(
          child: BottomNavigationBar(
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
        ),
      ),
    );
  }
}
