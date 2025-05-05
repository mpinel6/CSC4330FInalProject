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
    });
    //below was taken out or never used
    String msg;
    if (_isPlayer1Turn) {
      msg = "Player 1 TEST YOUR LUCK";
    } else {
      msg = "Player 2 TEST YOUR LUCK";
    }
//STOPED REFACTORING HERE

    void showTestYourLuck(bool isPlayer1) {
      double sliderValue = 1;
      bool hasRolled = false;
      final random = Random();

      List<int> rolledNumbers;
      if (isPlayer1) {
        rolledNumbers = _player1UsedNumbers;
      } else {
        rolledNumbers = _player2UsedNumbers;
      }

      String rolledTxt;
      if (hasRolled) {
        rolledTxt = "Rolled";
      } else {
        rolledTxt = "Roll";
      }

      //this will be for the numbers that havent alr been rolled  also taken out
      List<int> availableNumbers = List.generate(6, (index) => index + 1)
          .where((num) => !rolledNumbers.contains(num))
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
                      msg,
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
                      onChanged: hasRolled
                          ? null
                          : (value) {
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
                    if ((isPlayer1 ? _player1UsedNumbers : _player2UsedNumbers)
                        .isNotEmpty) ...[
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
                      onPressed: hasRolled
                          ? null
                          : () {
                              setDialogState(() {
                                // Only roll from available numbers
                                if (availableNumbers.isNotEmpty) {
                                  int randomIndex =
                                      random.nextInt(availableNumbers.length);
                                  sliderValue =
                                      availableNumbers[randomIndex].toDouble();
                                  // Ctaken out, was here to check if they rolled bad
                                  if (isPlayer1) {
                                  } else {}
                                }

                                hasRolled = true;

                                //was here for token removal on roulette game
                                if (sliderValue.round() ==
                                    (isPlayer1
                                        ? _player1LuckyNumber
                                        : _player2LuckyNumber)) {
                                  setState(() {
                                    if (isPlayer1) {
                                      _player1Tokens = _player1Tokens > 0
                                          ? _player1Tokens - 1
                                          : 0;
                                    } else {
                                      _player2Tokens = _player2Tokens > 0
                                          ? _player2Tokens - 1
                                          : 0;
                                    }
                                  });

                                  // display lost token on bad roll - taken out
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
                                          ' ',
                                          style: const TextStyle(
                                            color: Colors.brown,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              // pop were for the pop ups to close them
                                              Navigator.of(context).pop();
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      child: Text(
                        rolledTxt,
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
            // Add hamburger menu button
            Positioned(
              top: 40,
              right: 20,
              child: Container(
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
            ),
            // Turn indicator at the top
            if (_hasDealt)
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.brown[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      displayTurn,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
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
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (_hasDealt) ...[
                      const SizedBox(
                          height: 60), // Add space for the turn indicator
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
                                            color:
                                                Colors.brown.withOpacity(0.3),
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
                          style: TextStyle(fontSize: 18, color: Colors.white),
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
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            // Card hand display at bottom right
            if (_hasDealt)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    height: 160,
                    width: MediaQuery.of(context).size.width - 40,
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
                            child: Container(
                              width: 120,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Image.asset(
                                      'assets/images/${card['value'].toLowerCase()}.jpg',
                                      width: 110,
                                      height: 150,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.brown.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            //if we dont have a top card we need one and display it for play
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
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(
          0,
          _isNavBarVisible ? 0 : 100,
          0,
        ),
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
      extendBody: true,
    );
  }
}
