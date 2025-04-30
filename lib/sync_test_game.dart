import 'package:flutter/material.dart';
import 'dart:async';
import 'multiplayer.dart';
import 'game_state_manager.dart';

class SyncTestGame extends StatefulWidget {
  final MultiplayerService multiplayerService;
  final bool isHost;
  final String gameCode;
  
  const SyncTestGame({
    super.key, 
    required this.multiplayerService,
    required this.isHost,
    required this.gameCode,
  });

  @override
  State<SyncTestGame> createState() => _SyncTestGameState();
}

class _SyncTestGameState extends State<SyncTestGame> {
  late GameStateManager _gameStateManager;
  StreamSubscription? _stateSubscription;
  
  // Simple game state properties for testing
  String gamePhase = 'waiting';
  int counter = 0;
  String lastAction = 'None';
  List<String> gameLog = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize game state manager
    _gameStateManager = GameStateManager(widget.multiplayerService);
    
    // Listen to game state updates
    _stateSubscription = _gameStateManager.stateStream.listen((state) {
      setState(() {
        gamePhase = state['gamePhase'] ?? 'waiting';
        counter = state['counter'] ?? 0;
        lastAction = state['lastAction'] ?? 'None';
        
        // Add to log
        gameLog.add('State updated: Phase=$gamePhase, Counter=$counter');
        if (gameLog.length > 10) gameLog.removeAt(0); // Keep log size manageable
      });
    });
    
    // If host, initialize the game state
    if (widget.isHost) {
      _gameStateManager.initializeGameState(true, ['Host', 'Client']);
    }
  }
  
  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  void _startGame() {
    if (!widget.isHost) return; // Only host can start
    
    _gameStateManager.handlePlayerAction('host', 'startGame', {
      'startTime': DateTime.now().toString(),
    });
  }
  
  void _incrementCounter() {
    _gameStateManager.handlePlayerAction(
      widget.isHost ? 'host' : 'client',
      'incrementCounter', 
      {'amount': 1}
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sync Test - ${widget.isHost ? "HOST" : "CLIENT"}'),
        backgroundColor: Colors.brown[700],
      ),
      body: Container(
        color: Colors.brown[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Game info panel
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.brown[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    Text('Game Code: ${widget.gameCode}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('You are: ${widget.isHost ? "HOST" : "CLIENT"}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Game Phase: $gamePhase',
                      style: TextStyle(
                        color: gamePhase == 'playing' ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Counter: $counter',
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text('Last Action: $lastAction'),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Game controls
              if (widget.isHost && gamePhase == 'waiting')
                ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('START GAME', style: TextStyle(color: Colors.white)),
                ),
                
              if (gamePhase == 'playing')
                ElevatedButton(
                  onPressed: _incrementCounter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('INCREMENT COUNTER', style: TextStyle(color: Colors.white)),
                ),
                
              const SizedBox(height: 20),
                
              // Game log
              const Text('Game Log:', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.brown[50],
                    border: Border.all(color: Colors.brown),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListView.builder(
                    itemCount: gameLog.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Text(gameLog[index]),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}