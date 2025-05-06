import 'dart:async';
import 'dart:convert';
import 'multiplayer.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

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
  
  // Update the message listener to handle client actions
void _setUpMessageListener() {
  _multiplayerService.gameDataStream.listen(
    (data) {
      try {
        print('GameStateManager received data: ${data.toString().substring(0, min(100, data.toString().length))}');
        
        // Handle game state updates
        if (data['type'] == 'game_state_update' && data.containsKey('data')) {
          print('Processing state update');
          _updateState(data['data']);
        } 
        // Handle game actions directly
        else if (data['type'] == 'game_action') {
          print('Processing game action: ${data['action']}');
          final action = data['action'];
          
          if (action == 'incrementCounter') {
            final playerName = data['playerName'] ?? 'Unknown';
            print('Increment from $playerName');
            
            // Update counter for everyone
            final newCounter = (_currentState['counter'] ?? 0) + 1;
            _updateState({
              'counter': newCounter,
              'lastClicker': playerName
            });
            
            // Host should broadcast the update to everyone
            if (_multiplayerService.isHost) {
              _broadcastState();
            }
          }
        }
      } catch (e) {
        print('Error processing GameStateManager data: $e');
      }
    },
    onError: (error) {
      print('GameStateManager stream error: $error');
    }
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
  print('Increment counter called by $playerName');
  
  if (_multiplayerService.isHost) {
    // Host implementation
    final newCounter = (_currentState['counter'] ?? 0) + 1;
    
    print('HOST: Incrementing counter to $newCounter');
    
    _updateState({
      'counter': newCounter,
      'lastClicker': playerName
    });
    
    // Send to clients
    _broadcastState();
  } else {
    // Client implementation
    print('CLIENT: Sending increment action to host');
    
    // Send action to host with player name
    _multiplayerService.sendGameAction('incrementCounter', {
      'playerName': playerName
    });
  }
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
  try {
    print('Broadcasting state update: $_currentState');
    
    // Format update message
    final updateMessage = {
      'type': 'game_state_update',
      'data': _currentState,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };
    
    // Send with newline for reliable parsing
    final jsonStr = jsonEncode(updateMessage) + '\n';
    
    // Send directly to sockets if possible
    if (_multiplayerService.isHost) {
      for (final client in _multiplayerService.connectedClients) {
        client.write(jsonStr);
      }
    }
    
    // Also notify through controller
    _multiplayerService.addToGameData(updateMessage);
  } catch (e) {
    print('Error broadcasting state: $e');
  }
}
  
  void dispose() {
    _stateController.close();
  }
}