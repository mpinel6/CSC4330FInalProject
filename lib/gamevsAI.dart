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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _hasDealt = false;
  bool _hasSecondPlayer = true;
  bool _isPlayer1Turn = true;
  bool _hasPressedLiar = false;
  bool _isPlayerCallingLiar = false;
  bool _isNavBarVisible = false;
  List<Map<String, dynamic>> _selectedCards = [];
  List<Map<String, dynamic>> _player2Cards = [];
  late List<AnimationController> _cardControllers;
  late List<Animation<Offset>> _cardAnimations;
  late AnimationController _playIndicatorController;
  late Animation<double> _playIndicatorOpacity;
  late Animation<Offset> _playCardSlide;
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

  // Define text styles
  static const TextStyle _titleStyle = TextStyle(
    fontFamily: 'Zubilo',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.brown,
  );

  static const TextStyle _subtitleStyle = TextStyle(
    fontFamily: 'Zubilo',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.brown,
  );

  static const TextStyle _buttonStyle = TextStyle(
    fontFamily: 'Zubilo',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle _cpuStyle = TextStyle(
    fontFamily: 'Zubilo',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(offset: Offset(-2, -2), color: Colors.black),
      Shadow(offset: Offset(2, -2), color: Colors.black),
      Shadow(offset: Offset(-2, 2), color: Colors.black),
      Shadow(offset: Offset(2, 2), color: Colors.black),
      Shadow(offset: Offset(0, -2), color: Colors.black),
      Shadow(offset: Offset(0, 2), color: Colors.black),
      Shadow(offset: Offset(-2, 0), color: Colors.black),
      Shadow(offset: Offset(2, 0), color: Colors.black),
    ],
  );

  static const TextStyle _cpuTokenStyle = TextStyle(
    fontFamily: 'Zubilo',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(offset: Offset(-2, -2), color: Colors.black),
      Shadow(offset: Offset(2, -2), color: Colors.black),
      Shadow(offset: Offset(-2, 2), color: Colors.black),
      Shadow(offset: Offset(2, 2), color: Colors.black),
      Shadow(offset: Offset(0, -2), color: Colors.black),
      Shadow(offset: Offset(0, 2), color: Colors.black),
      Shadow(offset: Offset(-2, 0), color: Colors.black),
      Shadow(offset: Offset(2, 0), color: Colors.black),
    ],
  );

  static const TextStyle _gameStatusStyle = TextStyle(
    fontFamily: 'Zubilo',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(offset: Offset(-2, -2), color: Colors.black),
      Shadow(offset: Offset(2, -2), color: Colors.black),
      Shadow(offset: Offset(-2, 2), color: Colors.black),
      Shadow(offset: Offset(2, 2), color: Colors.black),
      Shadow(offset: Offset(0, -2), color: Colors.black),
      Shadow(offset: Offset(0, 2), color: Colors.black),
      Shadow(offset: Offset(-2, 0), color: Colors.black),
      Shadow(offset: Offset(2, 0), color: Colors.black),
    ],
  );

  late AnimationController _topCardController;
  late Animation<Offset> _topCardSlide;
  Map<String, AnimationController> _cardLiftControllers = {};
  Map<String, Animation<double>> _cardLiftAnimations = {};
  late AnimationController _cpuPlayController;
  late Animation<double> _cpuPlayOpacity;
  late Animation<Offset> _cpuPlaySlide;

  @override
  void initState() {
    super.initState();
    _cardControllers = List.generate(
        5,
        (_) => AnimationController(
              duration: const Duration(milliseconds: 400),
              vsync: this,
            ));
    _cardAnimations = List.generate(5, (index) {
      return Tween<Offset>(
        begin: _getCardStartPosition(index, 5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _cardControllers[index],
        curve: Curves.easeOutBack,
      ));
    });

    // Initialize play indicator animations
    _playIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _playIndicatorOpacity = Tween<double>(
      begin: 0.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _playIndicatorController,
      curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
    ));
    _playCardSlide = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, -1.0),
    ).animate(CurvedAnimation(
      parent: _playIndicatorController,
      curve: const Interval(0.2, 0.3, curve: Curves.easeOutBack),
    ));

    // Initialize top card animation
    _topCardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _topCardSlide = Tween<Offset>(
      begin: const Offset(0.0, -2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _topCardController,
      curve: Curves.easeOutBack,
    ));

    // Initialize CPU play indicator animations with longer duration
    _cpuPlayController = AnimationController(
      duration:
          const Duration(milliseconds: 4000), // Increased from 2000 to 4000
      vsync: this,
    );
    _cpuPlayOpacity = Tween<double>(
      begin: 0.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _cpuPlayController,
      curve: const Interval(0.0, 0.15, curve: Curves.easeIn), // Faster fade in
    ));
    _cpuPlaySlide = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cpuPlayController,
      curve: const Interval(0.15, 0.25,
          curve: Curves.easeOutBack), // Faster slide in
    ));
  }

  // Calculate the start position for each card based on its index
  Offset _getCardStartPosition(int index, int totalCards) {
    // Calculate the horizontal offset based on the card's final position
    // For 5 cards, we want positions like: 2, 1, 0, -1, -2
    double horizontalOffset = -((index - (totalCards - 1) / 2) * 0.5);
    return Offset(horizontalOffset, 2.0);
  }

  @override
  void dispose() {
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    for (var controller in _cardLiftControllers.values) {
      controller.dispose();
    }
    _playIndicatorController.dispose();
    _topCardController.dispose();
    _cpuPlayController.dispose();
    super.dispose();
  }

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

      // Trigger card animations
      for (int i = 0; i < _selectedCards.length; i++) {
        _cardControllers[i].reset();
        Future.delayed(Duration(milliseconds: 150 * i), () {
          _cardControllers[i].forward();
        });
      }

      // Show play indicator after a short delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        _showPlayIndicator();
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

  void _showPlayIndicator() {
    _playIndicatorController.reset();
    _playIndicatorController.forward().then((_) {
      // Start top card animation after play indicator completes
      _topCardController.reset();
      _topCardController.forward();
    });
  }

  void _showCpuPlayIndicator(int numCards, bool isLiarCall, [bool? isCorrect]) {
    _cpuPlayController.reset();
    _cpuPlayController.forward().then((_) {
      // Only reset the liar state if it's a CPU play, not a liar call
      if (!isLiarCall) {
        setState(() {
          _hasPressedLiar = false;
        });
      }
    });
  }

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
          _hasPressedLiar = false;
          _isPlayerCallingLiar = false;
        });
        _showCpuPlayIndicator(1, false);
      } else {
        // Check if all cards match the top card or is a joker
        bool allCardsMatch = _lastPlayedCards.every((card) =>
            card['value'] == _topLeftCard || card['value'] == 'Joker');

        setState(() {
          _lastPlayedCards = [playCard];
          _player2Cards.removeAt(0);
          _player2CardSelections.clear();
          _isPlayer1Turn = true;
          _hasPressedLiar = true;
          _isPlayerCallingLiar = false;
        });
        _showCpuPlayIndicator(1, true, allCardsMatch);
      }
    }
  }

  void _playSelectedCards() {
    setState(() {
      if (_isPlayer1Turn) {
        _lastPlayedCards = _selectedCards
            .where((card) => _cardSelections['${card['id']}'] == true)
            .toList();
        _selectedCards
            .removeWhere((card) => _cardSelections['${card['id']}'] == true);
        _cardSelections.clear();
      }
      _isPlayer1Turn = false;
      if (!_isPlayer1Turn && _hasSecondPlayer) {
        Future.delayed(const Duration(seconds: 1), _cpuTurn);
      }
      // Reset liar state when new cards are played
      _hasPressedLiar = false;
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
      _hasPressedLiar = true;
      _isPlayerCallingLiar = true;
    });

    // Check if all cards match the top card or is a joker
    bool allCardsMatch = _lastPlayedCards.every(
        (card) => card['value'] == _topLeftCard || card['value'] == 'Joker');

    // Show the liar animation
    _showCpuPlayIndicator(0, true, allCardsMatch);

    // Update tokens after animation
    Future.delayed(const Duration(milliseconds: 4000), () {
      setState(() {
        if (allCardsMatch) {
          if (_isPlayer1Turn && _player1Tokens > 0) {
            _player1Tokens -= 1;
          }
        } else {
          if (_player2Tokens > 0) {
            _player2Tokens -= 1;
          }
        }
        // Reset the liar caller state
        _isPlayerCallingLiar = false;
      });
    });
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

  void _initializeCardLiftAnimation(String cardId) {
    if (!_cardLiftControllers.containsKey(cardId)) {
      _cardLiftControllers[cardId] = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _cardLiftAnimations[cardId] = Tween<double>(
        begin: 0.0,
        end: -25.0,
      ).animate(CurvedAnimation(
        parent: _cardLiftControllers[cardId]!,
        curve: Curves.easeInOut,
      ));
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
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    top: MediaQuery.of(context).size.height * 0.25,
                    bottom: _isNavBarVisible ? kBottomNavigationBarHeight : 0,
                    left: 0,
                    right: 0,
                    child: Stack(
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/middlesprite.png',
                            fit: BoxFit.contain,
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.7,
                          ),
                        ),
                        if (_hasDealt && _hasSecondPlayer)
                          Align(
                            alignment: const Alignment(-0.03, -1.3),
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('CPU', style: _cpuStyle),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.stars,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 6),
                                  Text('$_player2Tokens',
                                      style: _cpuTokenStyle),
                                ],
                              ),
                            ),
                          ),
                      ],
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
                        SlideTransition(
                          position: _topCardSlide,
                          child: Container(
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
                                  style: _gameStatusStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_hasDealt)
                            Text(
                              displayTurn,
                              style: _gameStatusStyle,
                            ),
                          const SizedBox(width: 20),
                          if (_hasDealt)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.stars,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$_player1Tokens',
                                  style: _cpuTokenStyle,
                                ),
                              ],
                            ),
                          const SizedBox(width: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
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
                                // Removed Player 2 Hand section since it's now above the middle sprite
                              ],
                            ),
                          ],
                          if (!_hasDealt) ...[
                            ElevatedButton(
                              onPressed: _dealCards,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 6,
                              ),
                              child: const Text(
                                'Deal Cards',
                                style: _gameStatusStyle,
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
                if (_hasDealt && _isPlayer1Turn)
                  Column(
                    children: [
                      if (_cardSelections.values.any((selected) => selected))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: IconButton(
                            onPressed: _playSelectedCards,
                            icon: Image.asset(
                              'assets/images/thumbsup.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                      Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width - 40,
                        margin: const EdgeInsets.only(bottom: 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedCards.length,
                                  itemBuilder: (context, index) {
                                    final card = _selectedCards[index];
                                    final isSelected =
                                        _cardSelections['${card['id']}'] ??
                                            false;
                                    final cardId = '${card['id']}';

                                    _initializeCardLiftAnimation(cardId);

                                    if (isSelected) {
                                      _cardLiftControllers[cardId]?.forward();
                                    } else {
                                      _cardLiftControllers[cardId]?.reverse();
                                    }

                                    return SlideTransition(
                                      position: _cardAnimations[index],
                                      child: AnimatedBuilder(
                                        animation: _cardLiftAnimations[cardId]!,
                                        builder: (context, child) {
                                          return Transform.translate(
                                            offset: Offset(
                                                0,
                                                _cardLiftAnimations[cardId]!
                                                    .value),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _cardSelections[cardId] =
                                                      !isSelected;
                                                });
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                width: 60,
                                                height: 90,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4),
                                                decoration: isSelected
                                                    ? BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.yellow,
                                                            width: 3),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.yellow
                                                                .withOpacity(
                                                                    0.3),
                                                            spreadRadius: 2,
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, -2),
                                                          ),
                                                        ],
                                                      )
                                                    : null,
                                                child: Image.asset(
                                                  'assets/images/${card['value'].toLowerCase()}.jpg',
                                                  width: 60,
                                                  height: 90,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            // Liar button at bottom right
            if (_hasDealt)
              Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: (!_isPlayer1Turn ||
                          _hasPressedLiar ||
                          _lastPlayedCards.isEmpty)
                      ? null
                      : _checkLiar,
                  child: ColorFiltered(
                    colorFilter: (_hasPressedLiar || _lastPlayedCards.isEmpty)
                        ? const ColorFilter.matrix([
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ])
                        : const ColorFilter.matrix([
                            1,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                    child: Opacity(
                      opacity: (!_isPlayer1Turn ||
                              _hasPressedLiar ||
                              _lastPlayedCards.isEmpty)
                          ? 0.5
                          : 1.0,
                      child: Image.asset(
                        'assets/images/liarbutton.png',
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ),
                ),
              ),
            // Play indicator overlay
            _buildPlayIndicator(),
            _buildCpuPlayIndicator(),
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
            selectedItemColor: const Color(0xFF232323),
            unselectedItemColor: const Color(0xFFB0B0B0),
            backgroundColor: const Color(0xFFD6D6D6),
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayIndicator() {
    return AnimatedBuilder(
      animation: _playIndicatorController,
      builder: (context, child) {
        final value = _playIndicatorController.value;

        // Calculate opacity with strict bounds
        double opacity = 0.0;
        if (value <= 0.2) {
          opacity = (value / 0.2) * 0.7; // Fade in
        } else if (value >= 0.7) {
          opacity = (1.0 - ((value - 0.7) / 0.3)) * 0.7; // Fade out
        } else {
          opacity = 0.7; // Full opacity during hold
        }
        opacity = opacity.clamp(0.0, 0.7);

        // Calculate position with strict bounds
        double currentY = 0.0;
        if (value <= 0.3) {
          // Slide in
          double progress = (value / 0.3).clamp(0.0, 1.0);
          currentY = 1.0 - Curves.easeOutCubic.transform(progress);
        } else if (value >= 0.7) {
          // Slide out
          double progress = ((value - 0.7) / 0.3).clamp(0.0, 1.0);
          currentY = -Curves.easeInCubic.transform(progress);
        }
        // Between 0.3 and 0.7, stay at center (currentY = 0.0)

        return Visibility(
          visible: value > 0,
          child: IgnorePointer(
            ignoring: value >= 1.0, // Ignore touches when animation is complete
            child: Stack(
              children: [
                // Semi-transparent black overlay
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(opacity),
                  ),
                ),
                // Play card and text
                Center(
                  child: Transform.translate(
                    offset: Offset(
                        0, currentY * MediaQuery.of(context).size.height),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_topLeftCard != null)
                          Image.asset(
                            'assets/images/${_topLeftCard!.toLowerCase()}.jpg',
                            width: 120,
                            height: 180,
                          ),
                        const SizedBox(height: 20),
                        Text(
                          '${_topLeftCard?.toUpperCase() ?? ""}\'S TABLE',
                          style: TextStyle(
                            fontFamily: 'Zubilo',
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                  offset: Offset(-2, -2), color: Colors.black),
                              Shadow(
                                  offset: Offset(2, -2), color: Colors.black),
                              Shadow(
                                  offset: Offset(-2, 2), color: Colors.black),
                              Shadow(offset: Offset(2, 2), color: Colors.black),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCpuPlayIndicator() {
    return AnimatedBuilder(
      animation: _cpuPlayController,
      builder: (context, child) {
        // Calculate opacity with strict bounds
        double opacity = 0.0;
        if (_cpuPlayController.value <= 0.2) {
          opacity = (_cpuPlayController.value / 0.2) * 0.7; // Fade in
        } else if (_cpuPlayController.value >= 0.7) {
          opacity = (1.0 - ((_cpuPlayController.value - 0.7) / 0.3)) *
              0.7; // Fade out
        } else {
          opacity = 0.7; // Full opacity during hold
        }
        opacity = opacity.clamp(0.0, 0.7);

        // Calculate position with strict bounds
        double currentY = 0.0;
        if (_cpuPlayController.value <= 0.3) {
          // Slide in
          double progress = (_cpuPlayController.value / 0.3).clamp(0.0, 1.0);
          currentY = 1.0 - Curves.easeOutCubic.transform(progress);
        } else if (_cpuPlayController.value >= 0.7) {
          // Slide out
          double progress =
              ((_cpuPlayController.value - 0.7) / 0.3).clamp(0.0, 1.0);
          currentY = -Curves.easeInCubic.transform(progress);
        }
        // Between 0.3 and 0.7, stay at center (currentY = 0.0)

        return Visibility(
          visible:
              _cpuPlayController.value > 0 && _cpuPlayController.value < 1.0,
          child: IgnorePointer(
            ignoring: _cpuPlayController.value >= 1.0,
            child: Stack(
              children: [
                // Semi-transparent black overlay
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(opacity),
                  ),
                ),
                // CPU play indicator
                Center(
                  child: Transform.translate(
                    offset: Offset(
                        0, currentY * MediaQuery.of(context).size.height),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_hasPressedLiar) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < _lastPlayedCards.length; i++)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Image.asset(
                                    'assets/images/back.jpg',
                                    width: 80,
                                    height: 120,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'CPU PLAYS ${_lastPlayedCards.length} CARD${_lastPlayedCards.length > 1 ? 'S' : ''}',
                            style: TextStyle(
                              fontFamily: 'Zubilo',
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                    offset: Offset(-2, -2),
                                    color: Colors.black),
                                Shadow(
                                    offset: Offset(2, -2), color: Colors.black),
                                Shadow(
                                    offset: Offset(-2, 2), color: Colors.black),
                                Shadow(
                                    offset: Offset(2, 2), color: Colors.black),
                              ],
                            ),
                          ),
                        ] else ...[
                          Text(
                            _isPlayerCallingLiar
                                ? 'PLAYER CALLS CPU\'S BLUFF'
                                : 'CPU CALLS PLAYER\'S BLUFF',
                            style: TextStyle(
                              fontFamily: 'Zubilo',
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                    offset: Offset(-2, -2),
                                    color: Colors.black),
                                Shadow(
                                    offset: Offset(2, -2), color: Colors.black),
                                Shadow(
                                    offset: Offset(-2, 2), color: Colors.black),
                                Shadow(
                                    offset: Offset(2, 2), color: Colors.black),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'AND IS...',
                            style: TextStyle(
                              fontFamily: 'Zubilo',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                    offset: Offset(-2, -2),
                                    color: Colors.black),
                                Shadow(
                                    offset: Offset(2, -2), color: Colors.black),
                                Shadow(
                                    offset: Offset(-2, 2), color: Colors.black),
                                Shadow(
                                    offset: Offset(2, 2), color: Colors.black),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _lastPlayedCards.every((card) =>
                                    card['value'] == _topLeftCard ||
                                    card['value'] == 'Joker')
                                ? (_isPlayerCallingLiar
                                    ? 'INCORRECT! PLAYER LOSES -1'
                                    : 'INCORRECT! CPU LOSES -1')
                                : (_isPlayerCallingLiar
                                    ? 'CORRECT! CPU LOSES -1'
                                    : 'CORRECT! PLAYER LOSES -1'),
                            style: TextStyle(
                              fontFamily: 'Zubilo',
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                    offset: Offset(-2, -2),
                                    color: Colors.black),
                                Shadow(
                                    offset: Offset(2, -2), color: Colors.black),
                                Shadow(
                                    offset: Offset(-2, 2), color: Colors.black),
                                Shadow(
                                    offset: Offset(2, 2), color: Colors.black),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
