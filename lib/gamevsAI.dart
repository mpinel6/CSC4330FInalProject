import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<String> _discardPile = [];
  int _currentRound = 1;
  int _player1RoundWins = 0;
  int _player2RoundWins = 0;
  bool _isRoundOver = false;

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
  int maxCards3() {
    return _cardSelections.values.where((selected) => selected).length;
  }

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
  late AnimationController _dialogController;
  late Animation<double> _dialogAnimation;
  late AnimationController _announcementController;
  late Animation<double> _announcementOpacity;
  late Animation<Offset> _announcementSlide;
  List<Map<String, dynamic>> _announcements = [];
  static const int _maxAnnouncements = 3;
  static const double _announcementSpacing = 10.0;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

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

    // Initialize dialog animation
    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _dialogAnimation = CurvedAnimation(
      parent: _dialogController,
      curve: Curves.elasticOut,
    );

    // Initialize announcement animation
    _announcementController = AnimationController(
      duration: const Duration(milliseconds: 3000), // Reduced from 5000 to 3000
      vsync: this,
    );
    _announcementSlide = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _announcementController,
      curve: Curves.easeOutBack,
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
    _dialogController.dispose();
    _announcementController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _addSecondPlayer() {
    setState(() {
      _hasSecondPlayer = true;
    });
  }

  void _dealCards() {
    int requiredLength = 5; // one player 5 cards
    if (_hasSecondPlayer) {
      requiredLength = 10; // 2 players 10
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

        // Reset tokens for both players at the start of each round
        _player1Tokens = 3;
        _player2Tokens = 3;

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
      _showAnnouncement('Not enough cards left to deal!');
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

  void _endRound() {
    // Determine the winner of the current round
    bool player1WinsRound = _player1Tokens > _player2Tokens;

    setState(() {
      if (player1WinsRound) {
        _player1RoundWins++;
      } else {
        _player2RoundWins++;
      }
      _isRoundOver = true;
    });

    // Show round results dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Calculate dynamic font sizes based on screen size
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Base sizes on the smaller dimension to ensure consistency
        final baseSize = min(screenWidth, screenHeight);

        // Calculate font sizes
        final titleSize = baseSize * 0.08;
        final subtitleSize = baseSize * 0.045;
        final bodySize = baseSize * 0.04;
        final buttonSize = baseSize * 0.045;

        // Calculate dynamic spacing
        final tinySpacing = screenHeight * 0.01;
        final smallSpacing = screenHeight * 0.02;
        final mediumSpacing = screenHeight * 0.04;
        final largeSpacing = screenHeight * 0.06;
        final extraLargeSpacing = screenHeight * 0.12;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: ScaleTransition(
            scale: _dialogAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height *
                  0.9, // Increased from 0.8 to 0.9
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/wooduiupdatepanel.png'),
                  fit: BoxFit.contain,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.05, // Added vertical padding
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Changed to spaceBetween
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: tinySpacing),
                      Text(
                        'Round $_currentRound Complete!',
                        style: TextStyle(
                          fontFamily: 'Zubilo',
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(offset: Offset(-2, -2), color: Colors.black),
                            Shadow(offset: Offset(2, -2), color: Colors.black),
                            Shadow(offset: Offset(-2, 2), color: Colors.black),
                            Shadow(offset: Offset(2, 2), color: Colors.black),
                          ],
                        ),
                      ),
                      SizedBox(height: extraLargeSpacing),
                      Text(
                        player1WinsRound
                            ? 'You win this round!'
                            : 'CPU wins this round!',
                        style: TextStyle(
                          fontFamily: "Zubilo",
                          fontSize: subtitleSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(offset: Offset(-2, -2), color: Colors.black),
                            Shadow(offset: Offset(2, -2), color: Colors.black),
                            Shadow(offset: Offset(-2, 2), color: Colors.black),
                            Shadow(offset: Offset(2, 2), color: Colors.black),
                          ],
                        ),
                      ),
                      SizedBox(height: smallSpacing),
                      Text(
                        'Player tokens: $_player1Tokens',
                        style: TextStyle(
                          fontSize: bodySize,
                          color: Colors.white,
                          shadows: const [
                            Shadow(offset: Offset(-2, -2), color: Colors.black),
                            Shadow(offset: Offset(2, -2), color: Colors.black),
                            Shadow(offset: Offset(-2, 2), color: Colors.black),
                            Shadow(offset: Offset(2, 2), color: Colors.black),
                          ],
                        ),
                      ),
                      Text(
                        'CPU tokens: $_player2Tokens',
                        style: TextStyle(
                          fontSize: bodySize,
                          color: Colors.white,
                          shadows: const [
                            Shadow(offset: Offset(-2, -2), color: Colors.black),
                            Shadow(offset: Offset(2, -2), color: Colors.black),
                            Shadow(offset: Offset(-2, 2), color: Colors.black),
                            Shadow(offset: Offset(2, 2), color: Colors.black),
                          ],
                        ),
                      ),
                      SizedBox(height: smallSpacing),
                      Text(
                        'Match score: $_player1RoundWins - $_player2RoundWins',
                        style: TextStyle(
                          fontSize: bodySize,
                          color: Colors.white,
                          shadows: const [
                            Shadow(offset: Offset(-2, -2), color: Colors.black),
                            Shadow(offset: Offset(2, -2), color: Colors.black),
                            Shadow(offset: Offset(-2, 2), color: Colors.black),
                            Shadow(offset: Offset(2, 2), color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.1,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        _dialogController.reverse().then((_) {
                          Navigator.of(context).pop();
                          _startNewRound();
                        });
                      },
                      child: Text(
                        'Next Round',
                        style: TextStyle(
                          fontFamily: 'Zubilo',
                          fontSize: buttonSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(offset: Offset(-2, -2), color: Colors.black),
                            Shadow(offset: Offset(2, -2), color: Colors.black),
                            Shadow(offset: Offset(-2, 2), color: Colors.black),
                            Shadow(offset: Offset(2, 2), color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    _dialogController.forward();
  }

  void _startNewRound() {
    // Check if the match is over (best of 3)
    if (_player1RoundWins >= 2 ||
        _player2RoundWins >= 2 ||
        _currentRound >= 3) {
      _endMatch();
      return;
    }

    final random = Random();

    setState(() {
      // Increment round counter
      _currentRound++;

      // Reset round-specific state
      _hasDealt = false;
      _isPlayer1Turn = true;
      _hasPressedLiar = false;
      _isPlayerCallingLiar = false;
      _lastPlayedCards = [];
      _selectedCards = [];
      _player2Cards = [];
      _cardSelections = {};
      _player2CardSelections = {};

      // Reset tokens for both players
      _player1Tokens = 3;
      _player2Tokens = 3;

      // Reshuffle all cards back into deck
      if (_discardPile.isNotEmpty) {
        _deck.addAll(_discardPile);
        _discardPile.clear();
      }

      // Change the table card for the new round
      _topLeftCard = _topCards[random.nextInt(_topCards.length)];

      // Reset round over flag
      _isRoundOver = false;
    });
  }

  void _endMatch() {
    bool player1WinsMatch = _player1RoundWins > _player2RoundWins;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Calculate dynamic font sizes based on screen size
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Base sizes on the smaller dimension to ensure consistency
        final baseSize = min(screenWidth, screenHeight);

        // Calculate font sizes
        final titleSize = baseSize * 0.08;
        final subtitleSize = baseSize * 0.045;
        final bodySize = baseSize * 0.04;
        final buttonSize = baseSize * 0.045;

        // Calculate dynamic spacing
        final tinySpacing = screenHeight * 0.01;
        final smallSpacing = screenHeight * 0.02;
        final mediumSpacing = screenHeight * 0.04;
        final largeSpacing = screenHeight * 0.06;
        final extraLargeSpacing = screenHeight * 0.12;
        final superLargeSpacing = screenHeight * 0.15;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: ScaleTransition(
            scale: _dialogAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height *
                  0.9, // Increased from 0.8 to 0.9
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/wooduiupdatepanel.png'),
                  fit: BoxFit.contain,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.05, // Added vertical padding
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Changed to spaceBetween
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: tinySpacing),
                      Text(
                        'Match Complete!',
                        style: TextStyle(
                          fontFamily: 'Zubilo',
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(offset: Offset(-2, -2), color: Colors.black),
                            Shadow(offset: Offset(2, -2), color: Colors.black),
                            Shadow(offset: Offset(-2, 2), color: Colors.black),
                            Shadow(offset: Offset(2, 2), color: Colors.black),
                          ],
                        ),
                      ),
                      SizedBox(height: superLargeSpacing),
                      Text(
                        player1WinsMatch
                            ? 'Congratulations! You win the match!'
                            : 'CPU wins the match!',
                        style: TextStyle(
                          fontFamily: "Zubilo",
                          fontSize: subtitleSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(offset: Offset(-2, -2), color: Colors.black),
                            Shadow(offset: Offset(2, -2), color: Colors.black),
                            Shadow(offset: Offset(-2, 2), color: Colors.black),
                            Shadow(offset: Offset(2, 2), color: Colors.black),
                          ],
                        ),
                      ),
                      SizedBox(height: smallSpacing),
                      Text(
                        'Final score: $_player1RoundWins - $_player2RoundWins',
                        style: TextStyle(
                          fontSize: bodySize,
                          color: Colors.white,
                          shadows: const [
                            Shadow(offset: Offset(-2, -2), color: Colors.black),
                            Shadow(offset: Offset(2, -2), color: Colors.black),
                            Shadow(offset: Offset(-2, 2), color: Colors.black),
                            Shadow(offset: Offset(2, 2), color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.1,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        _dialogController.reverse().then((_) {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Gamevsai()),
                          );
                        });
                      },
                      child: Text(
                        'Play Again',
                        style: TextStyle(
                          fontFamily: 'Zubilo',
                          fontSize: buttonSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(offset: Offset(-2, -2), color: Colors.black),
                            Shadow(offset: Offset(2, -2), color: Colors.black),
                            Shadow(offset: Offset(-2, 2), color: Colors.black),
                            Shadow(offset: Offset(2, 2), color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    _dialogController.forward();
  }

  void _cpuTurn() {
    // First check if CPU needs cards
    if (_player2Cards.isEmpty) {
      // Check if we need to reshuffle first
      if (_deck.isEmpty && _discardPile.isNotEmpty) {
        _reshuffleDiscardPile();
      }

      // Try to replenish CPU's cards after potential reshuffle
      _replenishCpuCards();

      // If still empty after replenishment attempt, pass turn
      if (_player2Cards.isEmpty) {
        _showAnnouncement(
            'CPU has no cards and no more cards available! Passing turn.');
        setState(() {
          _isPlayer1Turn = true;
        });
        return;
      }
    }

    // Now that we've handled card replenishment, proceed with normal CPU turn
    final random = Random();

    // IMPROVED: AI decision making - 30% chance to call liar if possible
    bool shouldCallLiar =
        _lastPlayedCards.isNotEmpty && random.nextDouble() < 0.3;

    if (shouldCallLiar) {
      // CPU calls liar (if possible)
      setState(() {
        _hasPressedLiar = true;
        _isPlayerCallingLiar = false; // CPU is calling liar, not the player
      });

      // Check if all cards match the top card or are jokers
      bool allCardsMatch = _lastPlayedCards.every(
          (card) => card['value'] == _topLeftCard || card['value'] == 'Joker');

      _showCpuPlayIndicator(0, true, allCardsMatch);

      // Update tokens and state after animation finishes
      Future.delayed(const Duration(milliseconds: 4000), () {
        setState(() {
          if (allCardsMatch) {
            // CPU was wrong - CPU loses a token
            _player2Tokens -= 1;
          } else {
            // CPU was right - Player loses a token
            _player1Tokens -= 1;
          }
          _isPlayer1Turn = true;

          // Move the last played cards to discard pile after resolving liar call
          for (var card in _lastPlayedCards) {
            _discardPile.add(card['value']);
          }
          _lastPlayedCards = [];
        });

        // Check if game is over
        _checkGameOver();
      });
    } else {
      // CPU plays cards
      // IMPROVED: Find all matching cards (matching current type or jokers)
      List<Map<String, dynamic>> matchingCards = _player2Cards
          .where((card) =>
              card['value'] == _topLeftCard || card['value'] == 'Joker')
          .toList();

      // IMPROVED: Group cards by value to find duplicates
      Map<String, List<Map<String, dynamic>>> cardsByValue = {};
      for (var card in _player2Cards) {
        if (!cardsByValue.containsKey(card['value'])) {
          cardsByValue[card['value']] = [];
        }
        cardsByValue[card['value']]!.add(card);
      }

      List<Map<String, dynamic>> cardsToPlay = [];

      // IMPROVED: Strategy based on hand composition
      // Strategy 1: If we have matching cards, play them all (up to 3)
      if (matchingCards.isNotEmpty) {
        // Honest play with matching cards (max 3)
        cardsToPlay = matchingCards.take(min(3, matchingCards.length)).toList();
      }
      // Strategy 2: Play multiple cards of the same type if we have them
      else if (cardsByValue.values.any((cards) => cards.length > 1)) {
        // Find the most common card type we have
        String mostCommonType = '';
        int maxCount = 0;
        cardsByValue.forEach((type, cards) {
          if (cards.length > maxCount) {
            maxCount = cards.length;
            mostCommonType = type;
          }
        });

        // Play up to 3 of the most common card
        cardsToPlay =
            cardsByValue[mostCommonType]!.take(min(3, maxCount)).toList();

        // 70% chance to bluff that these are the required type
        bool shouldBluff = random.nextDouble() < 0.7;
        if (!shouldBluff) {
          // Play honestly (just one card)
          cardsToPlay = [cardsToPlay.first];
        }
      }
      // Strategy 3: Conservative play - just one random card
      else {
        cardsToPlay = [_player2Cards[random.nextInt(_player2Cards.length)]];
      }

      // Play the selected cards
      setState(() {
        _lastPlayedCards = cardsToPlay;

        // Add played cards to discard pile
        for (var card in cardsToPlay) {
          _discardPile.add(card['value']);
          // Remove from CPU's hand
          _player2Cards.remove(card);
        }

        _player2CardSelections.clear();
        _isPlayer1Turn = true;
        _hasPressedLiar = false;
        _isPlayerCallingLiar = false;
      });

      // Show indicator based on number of cards played
      _showCpuPlayIndicator(cardsToPlay.length, false);

      // Announce what the CPU did
      _showAnnouncement(
          'CPU played ${cardsToPlay.length} card${cardsToPlay.length > 1 ? 's' : ''}');

      // Check if CPU needs cards after playing
      if (_player2Cards.isEmpty) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          // Check if we need to reshuffle
          if (_deck.isEmpty && _discardPile.isNotEmpty) {
            _reshuffleDiscardPile();
          }

          _replenishCpuCards();
        });
      }
    }
  }

  void _checkGameOver() {
    if (_player1Tokens <= 0 || _player2Tokens <= 0) {
      // End the round when a player runs out of tokens
      Future.delayed(const Duration(milliseconds: 1000), () {
        _endRound();
      });
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

        for (var card in _lastPlayedCards) {
          _discardPile.add(card['value']);
        }

        _selectedCards
            .removeWhere((card) => _cardSelections['${card['id']}'] == true);
        _cardSelections.clear();

        // Check if player needs new cards
        if (_selectedCards.isEmpty) {
          _replenishPlayerCards();
        }
      }
      _isPlayer1Turn = false;
      if (!_isPlayer1Turn && _hasSecondPlayer) {
        Future.delayed(const Duration(seconds: 1), _cpuTurn);
      }
      // Reset liar state when new cards are played
      _hasPressedLiar = false;
    });
  }

  void _reshuffleDiscardPile() {
    if (_discardPile.isNotEmpty) {
      setState(() {
        // Move all cards from discard pile back to the deck
        _deck.addAll(_discardPile);
        _discardPile.clear();

        // Shuffle the deck
        final random = Random();
        _deck.shuffle(random);
      });

      _showAnnouncement('Discard pile reshuffled into the deck!');
    }
  }

  void _replenishPlayerCards() {
    // First check if we need to reshuffle
    if (_deck.isEmpty && _discardPile.isNotEmpty) {
      _reshuffleDiscardPile();
    }

    // If deck is still empty after potential reshuffle, show message and return
    if (_deck.isEmpty) {
      _showAnnouncement('No cards available to draw!');
      return;
    }

    // Generate 5 new cards (or fewer if deck is low)
    final cardsToAdd = min(5, _deck.length);

    final random = Random();
    List<Map<String, dynamic>> newCards = [];

    for (int i = 0; i < cardsToAdd; i++) {
      final cardIndex = random.nextInt(_deck.length);
      newCards.add({
        'id': 100 + i,
        'value': _deck[cardIndex],
      });
      _deck.removeAt(cardIndex);
    }

    setState(() {
      _selectedCards = newCards;
      _cardSelections = {
        for (var card in _selectedCards) '${card['id']}': false
      };
    });

    _showAnnouncement('You drew $cardsToAdd new cards!');
  }

  void _replenishCpuCards() {
    if (_deck.isEmpty) {
      _showAnnouncement('No cards available for CPU to draw!');
      return;
    }

    // Generate 5 new cards (or fewer if deck is low)
    final cardsToAdd = min(5, _deck.length);

    final random = Random();
    List<Map<String, dynamic>> newCards = [];

    for (int i = 0; i < cardsToAdd; i++) {
      final cardIndex = random.nextInt(_deck.length);
      newCards.add({
        'id': 200 + i,
        'value': _deck[cardIndex],
      });
      _deck.removeAt(cardIndex);
    }

    setState(() {
      _player2Cards = newCards;
      _player2CardSelections = {
        for (var card in _player2Cards) '${card['id']}': false
      };
    });

    _showAnnouncement('CPU drew $cardsToAdd new cards!');
  }

  void _checkLiar() {
    if (_lastPlayedCards.isEmpty) {
      _showAnnouncement('No cards have been played yet!');
      return;
    }

    setState(() {
      _hasPressedLiar = true;
      _isPlayerCallingLiar = true; // Player is calling liar
    });

    // Check if all cards match the claimed card type or are jokers
    bool allCardsMatch = _lastPlayedCards.every(
        (card) => card['value'] == _topLeftCard || card['value'] == 'Joker');

    // Show the liar animation
    _showCpuPlayIndicator(0, true, allCardsMatch);

    // Update tokens after animation
    Future.delayed(const Duration(milliseconds: 4000), () {
      setState(() {
        if (_isPlayerCallingLiar) {
          // Player called liar
          if (allCardsMatch) {
            // Cards matched - player's call was wrong - player loses token
            _player1Tokens -= 1;
          } else {
            // Cards didn't match - player's call was right - CPU loses token
            _player2Tokens -= 1;
          }
        } else {
          // CPU called liar
          if (allCardsMatch) {
            // Cards matched - CPU's call was wrong - CPU loses token
            _player2Tokens -= 1;
          } else {
            // Cards didn't match - CPU's call was right - player loses token
            _player1Tokens -= 1;
          }
        }

        // Add the played cards to discard pile
        for (var card in _lastPlayedCards) {
          _discardPile.add(card['value']);
        }

        // Clear the last played cards
        _lastPlayedCards = [];

        // Reset the liar caller state
        _isPlayerCallingLiar = false;
      });

      // Check if game is over due to token depletion
      _checkGameOver();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

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
                      // Round indicator
                      if (_hasDealt)
                        SlideTransition(
                          position: _topCardSlide,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            margin: const EdgeInsets.only(left: 45),
                            child: Text(
                              'Round $_currentRound of 3',
                              style: const TextStyle(
                                fontFamily: 'Zubilo',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                      offset: Offset(-2, -2),
                                      color: Colors.black),
                                  Shadow(
                                      offset: Offset(2, -2),
                                      color: Colors.black),
                                  Shadow(
                                      offset: Offset(-2, 2),
                                      color: Colors.black),
                                  Shadow(
                                      offset: Offset(2, 2),
                                      color: Colors.black),
                                ],
                              ),
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
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: IconButton(
                              icon: Icon(
                                _isNavBarVisible ? Icons.menu : Icons.menu_open,
                                color: Colors.white,
                                size: 32,
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
                            onPressed:
                                maxCards3() > 3 ? null : _playSelectedCards,
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
            _buildAnnouncement(),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _isNavBarVisible ? kBottomNavigationBarHeight + 20 : 0,
        child: SingleChildScrollView(
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Image.asset('assets/images/Beer.png',
                    width: 35, height: 35),
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
                        const SizedBox(height: 10),
                        Text(
                          'ROUND $_currentRound OF 3',
                          style: TextStyle(
                            fontFamily: 'Zubilo',
                            fontSize: 36,
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

  Widget _buildAnnouncement() {
    return AnimatedBuilder(
      animation: _announcementController,
      builder: (context, child) {
        return Visibility(
          visible: _announcementController.value > 0,
          child: Positioned(
            left: 20,
            bottom: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _announcements.asMap().entries.map((entry) {
                final index = entry.key;
                final announcement = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index < _announcements.length - 1
                          ? _announcementSpacing
                          : 0),
                  child: SlideTransition(
                    position: _announcementSlide,
                    child: Text(
                      announcement['message'],
                      style: const TextStyle(
                        fontFamily: 'Zubilo',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(offset: Offset(-1, -1), color: Colors.black),
                          Shadow(offset: Offset(1, -1), color: Colors.black),
                          Shadow(offset: Offset(-1, 1), color: Colors.black),
                          Shadow(offset: Offset(1, 1), color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showAnnouncement(String message) {
    // Remove the animation check since we want announcements to show during full-screen animations
    final now = DateTime.now();
    setState(() {
      _announcements.insert(0, {
        'message': message,
        'timestamp': now,
      });

      if (_announcements.length > _maxAnnouncements) {
        _announcements.removeLast();
      }
    });

    _announcementController.reset();
    _announcementController.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _announcementController.reverse().then((_) {
            if (mounted) {
              setState(() {
                if (_announcements.isNotEmpty) {
                  _announcements.removeLast();
                }
              });
            }
          });
        }
      });
    });
  }
}
