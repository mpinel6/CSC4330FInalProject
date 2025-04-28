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
  int requiredLength = 5;  //one player 5 cards
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
      // each player has a random number that is defined at dealing that will be the reason they lose 
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
    // out of cards
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not enough cards left in the deck!'),
        backgroundColor: Colors.brown,
      ),
    );
  }
}

void _cpuTurn(){
  if(_player2Cards.isNotEmpty){
    final randomMove = Random();
    int moveChoice = randomMove.nextInt(2)+1;
    var playCard = _player2Cards.first;

    if (moveChoice == 2){
    setState(() {
      _lastPlayedCards = [playCard];
      _player2Cards.removeAt(0);
      _player2CardSelections.clear();
      _isPlayer1Turn = true;
    
    });
    }else{
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
        _lastPlayedCards = _selectedCards.where((card) => _cardSelections['${card['id']}'] == true).toList();
        _selectedCards.removeWhere((card) => _cardSelections['${card['id']}'] == true);
        _cardSelections.clear();
      } 
      // Switch turns 
      _isPlayer1Turn = !_isPlayer1Turn;
      if (!_isPlayer1Turn && _hasSecondPlayer) {
  Future.delayed(const Duration(seconds: 1), _cpuTurn);
}
// Reset liar button
      _hasPressedLiar = false; 
      String displayWinner;
      if(_selectedCards.isEmpty){
        displayWinner = "Player 1 wins";
        }else{
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
                          MaterialPageRoute(builder: (context) => const MyApp()),
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
      //can only press liar button once 
      _hasPressedLiar = true; 
    });

    // Check if all cards match the top card or is a joker 
    bool allCardsMatch = _lastPlayedCards.every((card) => 
      card['value'] == _topLeftCard || card['value'] == 'Joker'
    );
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
      // If cards don't match (LIAR SHOULD DRINK), remove token from the other player
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
  String msg;
        if(_isPlayer1Turn){
            msg = "Player 1 TEST YOUR LUCK";
               }
                else{
            msg = "Player 2 TEST YOUR LUCK";
            }
//STOPED REFACTORING HERE
  
    void showTestYourLuck(bool isPlayer1) {
      double sliderValue = 1;
      bool hasRolled = false;
      final random = Random();


        List<int> rolledNumbers;
        if(isPlayer1){
          rolledNumbers = _player1UsedNumbers;
          }else{
          rolledNumbers = _player2UsedNumbers;
          }

               String rolledTxt;
                  if(hasRolled){
                      rolledTxt = "Rolled";
                  }else{
                      rolledTxt = "Roll";
                    }
        
      //this will be for the numbers that havent alr been rolled 
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
                // Show Test Your Luck for the player who should drink
                if (allCardsMatch) {
                  //showTestYourLuck(_isPlayer1Turn);
                } else {
                  //showTestYourLuck(!_isPlayer1Turn);
                }
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
    
    if (index == 0) { // Home button index
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
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
        String liarbutton;
    if(_lastPlayedCards.isEmpty&& _isPlayer1Turn){
      liarbutton = "No Cards Placed";
    }else if (_hasPressedLiar){
      liarbutton = "Liar(USED)";
      }else{
        liarbutton = "LIAR";
      }
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
                                      int maxCard3 = _cardSelections.values.where((selected) => selected).length;
                                      if (maxCard3 < 3 || value == false){
                                      setState(() {
                                        _cardSelections['${card['id']}'] = value ?? false;
                                      });
                                      }
                                    } : null,
                                    activeColor: Colors.brown[700],
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/${card['value'].toLowerCase()}.jpg',
                                        width: 40,
                                        height: 60,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        card['value'],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.brown,
                                        ),
                                      ),
                                    ],
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
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/back.jpg',
                                          width: 40,
                                          height: 60,
                                        ),
                                        const SizedBox(width: 8),
                                     
                                      ],
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
                          onPressed: _isPlayer1Turn ? () {
                           //disables the button for player 1 on ai turn
                            bool hasSelectedCards = _isPlayer1Turn
                                ? _cardSelections.values.any((selected) => selected)
                                : _player2CardSelections.values.any((selected) => selected);
                            
                            if (hasSelectedCards) {
                              _playSelectedCards();
                            }
                          }: null,

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
                          //disables player on ai turn
                          onPressed: (!_isPlayer1Turn ||_hasPressedLiar) ? null : _checkLiar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasPressedLiar ? Colors.grey : Colors.red[700],
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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

