import 'package:flutter/material.dart';
import 'rules_page.dart';
import 'settings.dart';
import 'main.dart';
import 'dart:math';
import 'dart:async';
import 'multiplayer.dart';
import 'game_state_manager.dart';

class LanCardGame extends StatefulWidget {
  final MultiplayerService multiplayerService;
  final bool isHost;
  final String gameCode;
  
  const LanCardGame({
    super.key, 
    required this.multiplayerService,
    required this.isHost,
    required this.gameCode,
  });

  @override
  State<LanCardGame> createState() => _LanCardGameState();
}

class _LanCardGameState extends State<LanCardGame> with TickerProviderStateMixin {
  int maxCards3() {
  if (widget.isHost) {
    return _cardSelections.values.where((selected) => selected).length;
  } else {
    return _player2CardSelections.values.where((selected) => selected).length;
  }
}
  late GameStateManager _gameStateManager;
  StreamSubscription? _stateSubscription;
  
  // Network status
  bool isConnected = true;
  List<String> gameLog = [];
  
  // Game state properties
  // Add these with other state properties:
  bool _isHostReady = false;
  bool _isClientReady = false;
  int _selectedIndex = 0;
  bool _hasDealt = false;
  bool _hasSecondPlayer = true;
  bool _isPlayer1Turn = true;
  bool _hasPressedLiar = false;
  bool _isPlayerCallingLiar = false;
  bool _isNavBarVisible = false;
  List<Map<String, dynamic>> _selectedCards = [];
  List<Map<String, dynamic>> _player2Cards = [];
  String? _topLeftCard;
  Map<String, bool> _cardSelections = {};
  Map<String, bool> _player2CardSelections = {};
  List<Map<String, dynamic>> _lastPlayedCards = [];
  int _player1Tokens = 3;
  int _player2Tokens = 3;
  int tableDisplayer = 0;
  List<String> _deck = [
    'Ace', 'Ace', 'Ace', 'Ace', 'Ace', 'Ace',
    'King', 'King', 'King', 'King', 'King', 'King',
    'Queen', 'Queen', 'Queen', 'Queen', 'Queen', 'Queen',
    'Joker', 'Joker'
  ];
  final List<String> _topCards = ['Ace', 'King', 'Queen'];

  // Animation controllers
  late List<AnimationController> _cardControllers;
  late List<Animation<Offset>> _cardAnimations;
  late AnimationController _playIndicatorController;
  late Animation<double> _playIndicatorOpacity;
  late Animation<Offset> _playCardSlide;
  late AnimationController _topCardController;
  late Animation<Offset> _topCardSlide;
  Map<String, AnimationController> _cardLiftControllers = {};
  Map<String, Animation<double>> _cardLiftAnimations = {};
  late AnimationController _cpuPlayController;
  late Animation<double> _cpuPlayOpacity;
  late Animation<Offset> _cpuPlaySlide;
  
  // Text styles
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

  @override
  void initState() {
    super.initState();
    
    // Initialize GameStateManager for multiplayer
    _gameStateManager = GameStateManager(widget.multiplayerService);
    
    // Set up debugging log
    gameLog.add('Initializing card game - ${widget.isHost ? "HOST" : "CLIENT"}');
    
    // Initialize animation controllers
    _setupAnimations();
    
    // Listen to state updates from network
    _stateSubscription = _gameStateManager.stateStream.listen(
      (state) {
        print('Received game state update: $state');
        if (mounted) {
          setState(() {
            // Update game state from network
            tableDisplayer = state['tableDisplayer'] ?? tableDisplayer;

            _hasDealt = state['hasDealt'] ?? _hasDealt;
            _isPlayer1Turn = state['isPlayer1Turn'] ?? _isPlayer1Turn;
            _hasPressedLiar = state['hasPressedLiar'] ?? _hasPressedLiar;
            _isPlayerCallingLiar = state['isPlayerCallingLiar'] ?? _isPlayerCallingLiar;

            _isHostReady = state['isHostReady'] ?? _isHostReady;
            _isClientReady = state['isClientReady'] ?? _isClientReady;

            _selectedCards = List<Map<String, dynamic>>.from(state['selectedCards'] ?? _selectedCards);
            _player2Cards = List<Map<String, dynamic>>.from(state['player2Cards'] ?? _player2Cards);
            _topLeftCard = state['topLeftCard'] ?? _topLeftCard;
            _cardSelections = Map<String, bool>.from(state['cardSelections'] ?? _cardSelections);
            _player2CardSelections = Map<String, bool>.from(state['player2CardSelections'] ?? _player2CardSelections);
            _lastPlayedCards = List<Map<String, dynamic>>.from(state['lastPlayedCards'] ?? _lastPlayedCards);
            _player1Tokens = state['player1Tokens'] ?? _player1Tokens;
            _player2Tokens = state['player2Tokens'] ?? _player2Tokens;
            _deck = List<String>.from(state['deck'] ?? _deck);
            
            // If cards were just dealt, trigger animations
            if (state.containsKey('cardsJustDealt') && state['cardsJustDealt'] == true) {
              _triggerCardAnimations();
            }
            
            // Update log with game state changes
            final timestamp = DateTime.now().toString().substring(11, 19);
            if (state.containsKey('logMessage')) {
              gameLog.add('[$timestamp] ${state['logMessage']}');
              if (gameLog.length > 20) gameLog.removeAt(0);
            }
          });
        }
      },
      onError: (error) {
        print('Error in state stream: $error');
        if (mounted) {
          setState(() {
            gameLog.add('Error: $error');
          });
        }
      }
    );
    
    // Initialize game state if host
    if (widget.isHost) {
      print('HOST: Initializing card game state');
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          _initializeGameState();
        }
      });
    }
    
    // Monitor connection status
    widget.multiplayerService.connectionStatus.listen((status) {
      print('Connection status: $status');
      if (mounted) {
        setState(() {
          isConnected = !status.contains('disconnected');
          gameLog.add('Connection: $status');
        });
      }
    });
  }

  void _setupAnimations() {
    // Initialize card animations
    _cardControllers = List.generate(
      5,
      (_) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      )
    );
    
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

    // Initialize CPU play indicator animations
    _cpuPlayController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    
    _cpuPlayOpacity = Tween<double>(
      begin: 0.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _cpuPlayController,
      curve: const Interval(0.0, 0.15, curve: Curves.easeIn),
    ));
    
    _cpuPlaySlide = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cpuPlayController,
      curve: const Interval(0.15, 0.25, curve: Curves.easeOutBack),
    ));
  }

  // Initialize game state on host
  void _initializeGameState() {
    if (widget.isHost) {
      final gameState = {
        'hasDealt': false,
        'isPlayer1Turn': true,
        'hasPressedLiar': false,
        'isPlayerCallingLiar': false,
        'selectedCards': [],
        'player2Cards': [],
        'topLeftCard': null,
        'cardSelections': {},
        'player2CardSelections': {},
        'lastPlayedCards': [],
        'player1Tokens': 3,
        'player2Tokens': 3,
        'deck': [
          'Ace', 'Ace', 'Ace', 'Ace', 'Ace', 'Ace',
          'King', 'King', 'King', 'King', 'King', 'King',
          'Queen', 'Queen', 'Queen', 'Queen', 'Queen', 'Queen',
          'Joker', 'Joker'
        ],
        'logMessage': 'Game initialized - waiting for deal'
      };
      
      _gameStateManager.updateState(gameState);
    }
  }
      void _toggleReady() {
        final bool newReadyState = widget.isHost ? !_isHostReady : !_isClientReady;
        
        setState(() {
          if (widget.isHost) {
            _isHostReady = newReadyState;
            _gameStateManager.updateState({'isHostReady': newReadyState});
          } else {
            _isClientReady = newReadyState;
            widget.multiplayerService.sendGameAction('clientReadyToggle', {
              'isClientReady': newReadyState
            });
          }
        });
      }

  // Deal cards across the network
  void _dealCards() {
    
      if (widget.isHost) {
      // Only proceed if both players are ready
      if (!(_isHostReady && _isClientReady)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waiting for both players to be ready!'),
            backgroundColor: Colors.brown,
          ),
        );
        return;
      }
      final random = Random();
      final shuffledDeck = List<String>.from(_deck)..shuffle(random);
      
      // Create player 1 cards (host)
      final player1Cards = shuffledDeck.take(5).toList().asMap().entries.map((entry) {
        return {
          'id': entry.key,
          'value': entry.value,
        };
      }).toList();
      
      // Create player 2 cards (client)
      final player2Cards = shuffledDeck.skip(5).take(5).toList().asMap().entries.map((entry) {
        return {
          'id': entry.key + 5,
          'value': entry.value,
        };
      }).toList();
      
      // Remove dealt cards from deck
      shuffledDeck.removeRange(0, 10);
      
      // Choose a top card
      final topCard = _topCards[random.nextInt(_topCards.length)];
      
      // Create selections maps
      final p1Selections = {
        for (var card in player1Cards) '${card['id']}': false
      };
      
      final p2Selections = {
        for (var card in player2Cards) '${card['id']}': false
      };
      
      // Update state with dealt cards
      final gameState = {
        'hasDealt': true,  // TRUE to show cards were dealt
        'isPlayer1Turn': true,
        'hasPressedLiar': false,
        'isPlayerCallingLiar': false,
        'selectedCards': player1Cards,  // Use the newly created cards
        'player2Cards': player2Cards,   // Use the newly created cards
        'topLeftCard': topCard,         // Use the selected top card
        'cardSelections': p1Selections,
        'player2CardSelections': p2Selections,
        'lastPlayedCards': [],
        'player1Tokens': 3,
        'player2Tokens': 3,
        // Keep ready states as they are - don't reset them
        'cardsJustDealt': true,  // Add this to trigger animations
        'deck': shuffledDeck,
        'logMessage': 'Cards dealt - ${topCard}\'s TABLE'  // Better message
      };
      
      _gameStateManager.updateState(gameState);
      
      // Trigger animations locally
      _triggerCardAnimations();
      
    } else {
      
      // Client should send deal request to host
      widget.multiplayerService.sendGameAction('dealCards', {});
       
    }
  }

  void _triggerCardAnimations() {
    // Reset and start card animations
    for (int i = 0; i < _cardControllers.length; i++) {
      _cardControllers[i].reset();
      Future.delayed(Duration(milliseconds: 150 * i), () {
        _cardControllers[i].forward();
      });
    }

    // Show play indicator after a short delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      _showPlayIndicator();
    });
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
      if (!isLiarCall && mounted) {
        setState(() {
          _hasPressedLiar = false;
        });
      }
    });
  }

  void _playSelectedCards() {
    if (widget.isHost && maxCards3() <= 3) {
      
      tableDisplayer = 1;
     
      // Host implementation
      final selectedCardsList = _selectedCards
          .where((card) => _cardSelections['${card['id']}'] == true)
          .toList();
      
      if (selectedCardsList.isEmpty) return;
      
      final remainingCards = _selectedCards
          .where((card) => _cardSelections['${card['id']}'] != true)
          .toList();
      
      // Check for win condition
      if (remainingCards.isEmpty) {
        _showWinDialog('Host');
        return;
      }
      
      // Send action through game state manager
      final gameState = {
        'selectedCards': remainingCards,
        'cardSelections': {},
        'lastPlayedCards': selectedCardsList,
        'isPlayer1Turn': false,
        'hasPressedLiar': false,
        'tableDisplayer': tableDisplayer,
        'logMessage': 'Host played ${selectedCardsList.length} card(s)'
      };
      
      _gameStateManager.updateState(gameState);
    } else {
      if(maxCards3() <= 3) {
    // Client implementation
    final selectedCardsList = _player2Cards // CHANGED: Use player2Cards for client
        .where((card) => _player2CardSelections['${card['id']}'] == true) // CHANGED: Use player2CardSelections
        .toList();
    
    if (selectedCardsList.isEmpty) return;
    
    // Send played cards to host
    widget.multiplayerService.sendGameAction('playCards', {
      'playedCards': selectedCardsList
    });
    
    // ADDED: Update client UI immediately for feedback
    setState(() {
      // Remove played cards from hand
      _player2Cards.removeWhere(
          (card) => _player2CardSelections['${card['id']}'] == true);
      _player2CardSelections.clear();
    });
    }
  }
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
    
    if (widget.isHost) {
      // Host implementation - check client's cards
      setState(() {
        _hasPressedLiar = true;
        _isPlayerCallingLiar = true;
      });

      // Check if all cards match the top card or is a joker
      bool allCardsMatch = _lastPlayedCards.every(
        (card) => card['value'] == _topLeftCard || card['value'] == 'Joker'
      );
      
      // Show animation
      _showCpuPlayIndicator(0, true, allCardsMatch);
      
      // Update tokens after animation
      Future.delayed(const Duration(milliseconds: 4000), () {
        if (!mounted) return;
        
        final Map<String, dynamic> gameState = {
          'hasPressedLiar': true,
          'isPlayerCallingLiar': false
        };
          
        // Update tokens based on the result
        if (allCardsMatch) {
          gameState['player1Tokens'] = _player1Tokens - 1;
          gameState['logMessage'] = 'Host called Liar incorrectly and lost a token';
        } else {
          gameState['player2Tokens'] = _player2Tokens - 1;
          gameState['logMessage'] = 'Host called Liar correctly! Client lost a token';
        }
        
        _gameStateManager.updateState(gameState);
      });
    } else {
      // Client implementation - send liar call to host
      widget.multiplayerService.sendGameAction('checkLiar', {});
    }
  }

  void _showWinDialog(String winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: Text('$winner has won the game!'),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to host/join screen
              },
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

  Offset _getCardStartPosition(int index, int totalCards) {
    // Calculate the horizontal offset based on the card's final position
    // For 5 cards, we want positions like: 2, 1, 0, -1, -2
    double horizontalOffset = -((index - (totalCards - 1) / 2) * 0.5);
    return Offset(horizontalOffset, 2.0);
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
  void dispose() {
    // Clean up controllers
    _stateSubscription?.cancel();
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

  @override
  Widget build(BuildContext context) {
    // Determine if it's my turn based on host status
    bool isMyTurn = widget.isHost ? _isPlayer1Turn : !_isPlayer1Turn;
    
    String displayTurn;
    if (_isPlayer1Turn) {
      displayTurn = widget.isHost ? 'Your Turn' : 'Host\'s Turn';
    } else {
      displayTurn = widget.isHost ? 'Client\'s Turn' : 'Your Turn';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Multiplayer Card Game - ${widget.isHost ? "HOST" : "CLIENT"}'),
        backgroundColor: widget.isHost ? Colors.brown[700] : Colors.brown[500],
      ),
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
                        if (_hasDealt)
                          Align(
                            alignment: const Alignment(-0.03, -1.3),
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Player 2 token display
                                  Text(
                                    widget.isHost ? 'Client' : 'Host', 
                                    style: _cpuStyle
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.stars,
                                    color: Colors.white, 
                                    size: 20
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$_player2Tokens',
                                    style: _cpuTokenStyle
                                  ),
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
                // Top section with status and tokens
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
                            child: Row(
                              children: [
                                Text(
                                  isConnected ? 'Connected' : 'Disconnected',
                                  style: TextStyle(
                                    color: isConnected ? Colors.green : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                                IconButton(
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
                              ],
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
                            // Game information
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Game Code: ${widget.gameCode}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Game log
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: ListView.builder(
                                itemCount: gameLog.length,
                                reverse: true,
                                itemBuilder: (context, index) {
                                  final entry = gameLog[gameLog.length - 1 - index];
                                  return Text(
                                    entry,
                                    style: TextStyle(color: Colors.white),
                                  );
                                },
                              ),
                            ),
                          ],
                          // Replace the if (!_hasDealt) section with:
                            if (!_hasDealt) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Host: ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          _isHostReady ? Icons.check_circle : Icons.circle_outlined,
                                          color: _isHostReady ? Colors.green : Colors.grey,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 24),
                                        const Text(
                                          'Client: ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          _isClientReady ? Icons.check_circle : Icons.circle_outlined,
                                          color: _isClientReady ? Colors.green : Colors.grey,
                                          size: 28,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: _toggleReady,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.brown[600],
                                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Text(
                                        widget.isHost
                                          ? (_isHostReady ? 'Not Ready' : 'Ready')
                                          : (_isClientReady ? 'Not Ready' : 'Ready'),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    if (widget.isHost) 
                                      ElevatedButton(
                                        onPressed: (_isHostReady && _isClientReady) ? _dealCards : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: (_isHostReady && _isClientReady) 
                                            ? Colors.black.withOpacity(0.5)
                                            : Colors.grey.withOpacity(0.5),
                                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
                                  ],
                                ),
                              ),
                            ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Card hand display
                if (_hasDealt && isMyTurn)
                  Column(
                    children: [
                      if ((widget.isHost && _cardSelections.values.any((selected) => selected)) || 
    (!widget.isHost && _player2CardSelections.values.any((selected) => selected)))
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
                                  itemCount: widget.isHost ? _selectedCards.length : _player2Cards.length, // Show different cards based on player
                                  itemBuilder: (context, index) {
                                    final card = widget.isHost ? _selectedCards[index] : _player2Cards[index]; // Choose correct card set
                                    final isSelected = widget.isHost
                                        ? (_cardSelections['${card['id']}'] ?? false)
                                        : (_player2CardSelections['${card['id']}'] ?? false); // Use correct selections
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
                                                  if (widget.isHost) {
                                                    _cardSelections[cardId] = !isSelected;
                                                  } else {
                                                    _player2CardSelections[cardId] = !isSelected;
                                                  }
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
                  onTap: ((!isMyTurn) ||
                          _hasPressedLiar ||
                          _lastPlayedCards.isEmpty)
                      ? null
                      : _checkLiar,
                  child: ColorFiltered(
                    colorFilter: (_hasPressedLiar || _lastPlayedCards.isEmpty)
                        ? const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0,      0,      0,      1, 0,
                          ])
                        : const ColorFilter.matrix([
                            1, 0, 0, 0, 0,
                            0, 1, 0, 0, 0,
                            0, 0, 1, 0, 0,
                            0, 0, 0, 1, 0,
                          ]),
                    child: Opacity(
                      opacity: ((!isMyTurn) ||
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
                if (tableDisplayer == 0)
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
                              Shadow(offset: Offset(-2, -2), color: Colors.black),
                              Shadow(offset: Offset(2, -2), color: Colors.black),
                              Shadow(offset: Offset(-2, 2), color: Colors.black),
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

        // Calculate position
        double currentY = 0.0;
        if (_cpuPlayController.value <= 0.3) {
          // Slide in
          double progress = (_cpuPlayController.value / 0.3).clamp(0.0, 1.0);
          currentY = 1.0 - Curves.easeOutCubic.transform(progress);
        } else if (_cpuPlayController.value >= 0.7) {
          // Slide out
          double progress = ((_cpuPlayController.value - 0.7) / 0.3).clamp(0.0, 1.0);
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
                            widget.isHost ? 
                              'PLAYER 2 PLAYS ${_lastPlayedCards.length} CARD${_lastPlayedCards.length > 1 ? 'S' : ''}' :
                              'PLAYER 1 PLAYS ${_lastPlayedCards.length} CARD${_lastPlayedCards.length > 1 ? 'S' : ''}',
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
                            widget.isHost ?
                              'PLAYER 1 CALLS PLAYER 2\'S BLUFF' :
                              'PLAYER 2 CALLS PLAYER 1\'S BLUFF',
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
                                ? 'INCORRECT! ${widget.isHost ? "PLAYER 1" : "PLAYER 2"} LOSES -1'
                                : 'CORRECT! ${widget.isHost ? "PLAYER 2" : "PLAYER 1"} LOSES -1',
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