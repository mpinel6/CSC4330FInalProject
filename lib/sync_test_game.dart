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
  
  // Simple game state properties
  int counter = 0;
  String lastClicker = 'None';
  List<String> clickLog = [];
  bool isConnected = true;
  
  @override
void initState() {
  super.initState();
  
  print('SyncTestGame initialization starting - ${widget.isHost ? "HOST" : "CLIENT"} mode');
  
  // Delay GameStateManager initialization
  Future.delayed(Duration(milliseconds: 500), () {
    if (!mounted) return;
    
    try {
      print('Creating GameStateManager');
      _gameStateManager = GameStateManager(widget.multiplayerService);
      
      print('Setting up state subscription');
      _stateSubscription = _gameStateManager.stateStream.listen(
        (state) {
          print('Received state update: $state');
          if (!mounted) return;
          
          setState(() {
            counter = state['counter'] ?? 0;
            lastClicker = state['lastClicker'] ?? 'None';
            clickLog.add('Counter: $counter (by $lastClicker)');
            if (clickLog.length > 20) clickLog.removeAt(0);
          });
        },
        onError: (e) {
          print('State stream error: $e');
          addErrorToLog('Stream error: $e');
        }
      );
      
      // Initialize game state if host
      if (widget.isHost) {
        print('Initializing click state as host');
        _gameStateManager.initializeClickerState();
      }
      
      print('SyncTestGame initialization complete');
      addInfoToLog('Game connected successfully');
      
    } catch (e) {
      print('ERROR in SyncTestGame init: $e');
      addErrorToLog('Setup error: $e');
    }
  });
}
  
  void addErrorToLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      clickLog.add('[$timestamp] ⚠️ $message');
      if (clickLog.length > 20) clickLog.removeAt(0);
    });
  }
  
  void addInfoToLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      clickLog.add('[$timestamp] ℹ️ $message');
      if (clickLog.length > 20) clickLog.removeAt(0);
    });
  }
  
  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  void _incrementCounter() {
    try {
      final playerName = widget.isHost ? 'Host' : 'Client';
      
      // Use a non-blocking async operation for the click
      Future.microtask(() {
        _gameStateManager.incrementCounter(playerName);
      });
      
      // Give immediate feedback in UI
      setState(() {
        // The state will be properly updated when the event circles back through the network
        clickLog.add('Sending click...');
      });
    } catch (e) {
      addErrorToLog('Click error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multiplayer Clicker - ${widget.isHost ? "HOST" : "CLIENT"}'),
        backgroundColor: widget.isHost ? Colors.deepPurple : Colors.indigo,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.isHost ? Colors.deepPurple[100]! : Colors.indigo[100]!,
              Colors.brown[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Game info panel
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Game Code: ${widget.gameCode}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You are: ${widget.isHost ? "HOST" : "CLIENT"}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.isHost ? Colors.deepPurple : Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Status: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isConnected ? 'Connected' : 'Disconnected',
                          style: TextStyle(
                            color: isConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          isConnected ? Icons.check_circle : Icons.error,
                          color: isConnected ? Colors.green : Colors.red,
                          size: 16,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Counter display
              Center(
                child: Column(
                  children: [
                    Text(
                      '$counter',
                      style: const TextStyle(
                        fontSize: 120, 
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastClicker == 'None' ? '' : 'Last click by: $lastClicker',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.brown[700],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Click button
              GestureDetector(
                onTap: _incrementCounter,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: widget.isHost ? Colors.deepPurple : Colors.indigo,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'CLICK ME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
                
              const SizedBox(height: 32),
                
              // Click log
              const Text(
                'Activity Log:', 
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    border: Border.all(color: Colors.brown.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListView.builder(
                    itemCount: clickLog.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final logEntry = clickLog[clickLog.length - 1 - index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Text(
                          logEntry,
                          style: TextStyle(
                            color: logEntry.contains('⚠️') 
                              ? Colors.red 
                              : Colors.black87,
                          ),
                        ),
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