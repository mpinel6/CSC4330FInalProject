import 'dart:async';
import 'dart:convert';
import 'multiplayer.dart';
import 'package:flutter/foundation.dart';

class GameStateManager {
  final MultiplayerService _multiplayerService;
  final _stateController = StreamController<Map<String, dynamic>>.broadcast();
  Map<String, dynamic> _currentState = {
    'counter': 0,
    'lastClicker': 'None',
  };
  
  Stream<Map<String, dynamic>> get stateStream => _stateController.stream;
  
  GameStateManager(this._multiplayerService) {
    // Listen to incoming messages and update state
    _setUpMessageListener();
  }
  
  void _setUpMessageListener() {
  _multiplayerService.gameDataStream.listen(
    (data) {
      try {
        // Check if this is a state update
        if (data['type'] == 'state_update' && data.containsKey('data')) {
          _updateState(data['data']);
        } 
        // Handle game_action events that might affect state
        else if (data['type'] == 'game_action') {
          // Process game actions if needed
          final action = data['action'];
          final actionData = data['data'] ?? {};
          handlePlayerAction(data['playerId'] ?? 'unknown', action, actionData);
        }
      } catch (e) {
        // Use a logger or ignore silently in production
        debugPrint('Error processing game data: $e');
      }
    },
    onError: (error) {
      debugPrint('Game data stream error: $error');
    },
  );
}
  
  void _updateState(Map<String, dynamic> newState) {
    // Merge new state with current state
    _currentState = {..._currentState, ...newState};
    
    // Notify listeners
    if (!_stateController.isClosed) {
      _stateController.add(_currentState);
    }
  }
  
  // Initialize the clicker game state
  void initializeClickerState() {
    _updateState({
      'counter': 0,
      'lastClicker': 'None'
    });
    
    _broadcastState();
  }
  
  // Increment the counter
  void incrementCounter(String playerName) {
    // Increment locally
    final newCounter = (_currentState['counter'] ?? 0) + 1;
    
    // Update state
    _updateState({
      'counter': newCounter,
      'lastClicker': playerName
    });
    
    // Send to other players
    _broadcastState();
  }
  
  // For backwards compatibility
  void initializeGameState(bool isHosting, List<String> players) {
    initializeClickerState();
  }
  
  // For backwards compatibility
  void handlePlayerAction(String playerId, String action, Map<String, dynamic> data) {
    if (action == 'incrementCounter') {
      incrementCounter(playerId);
    } else if (action == 'startGame') {
      // Nothing special needed for clicker
      _broadcastState();
    }
  }
  
  // Broadcast state to all connected clients
  void _broadcastState() {
  _multiplayerService.updateGameState(_currentState);
}
  
  void dispose() {
    _stateController.close();
  }
}