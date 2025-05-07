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
@override
void _setUpMessageListener() {
  _multiplayerService.gameDataStream.listen(
    (data) {
      try {
        print('GameStateManager received: ${data.toString().substring(0, min(100, data.toString().length))}');
        
        // Handle game state updates
        if (data['type'] == 'game_state_update' && data.containsKey('data')) {
          print('Processing state update');
          _updateState(data['data']);
        } 
        // Handle game actions specifically
        else if (data['type'] == 'game_action') {
          print('Processing game action: ${data['action']}');
          final action = data['action'];
          
          if (action == 'incrementCounter') {
            // Legacy clicker game action
            final playerName = data['playerName'] ?? 'Unknown';
            final newCounter = (_currentState['counter'] ?? 0) + 1;
            
            _updateState({
              'counter': newCounter,
              'lastClicker': playerName
            });
            
            if (_multiplayerService.isHost) {
              _broadcastState();
            }
          }
          else if (action == 'clientReadyToggle' && _multiplayerService.isHost) {
            // Host processing client's ready toggle
            print('Host received client ready toggle');
            final isClientReady = data['data']['isClientReady'] ?? false;
            
            // Update the state with the new ready status
            _updateState({'isClientReady': isClientReady});
            
            // Broadcast to all players (including the sender for confirmation)
            _broadcastState();
          }
          else if (action == 'dealCards' && _multiplayerService.isHost) {
            // Host should deal cards
            print('Host received deal cards request');
            // No implementation needed as the host UI should handle this
          }

          else if (action == 'playCards' && _multiplayerService.isHost) {
            // Host processing client's played cards
            final playedCards = data['data']['playedCards'];
            
            // Update host state to reflect client's move
            final gameState = {
              'lastPlayedCards': playedCards,
              'isPlayer1Turn': true, // Back to host's turn
              'hasPressedLiar': false,
              'logMessage': 'Client played ${playedCards.length} card(s)'
            };
            
            // ADD THIS NEW CODE: Update client's cards and clear selections
            final updatedPlayer2Cards = List<Map<String, dynamic>>.from(_currentState['player2Cards'] ?? []);
            updatedPlayer2Cards.removeWhere((card) => 
              playedCards.any((played) => played['id'] == card['id']));
            
            gameState['player2Cards'] = updatedPlayer2Cards;
            gameState['player2CardSelections'] = {};
            
            _updateState(gameState);
            _broadcastState();
          }


          else if (action == 'checkLiar' && _multiplayerService.isHost) {
            // Host processing client's liar call
            print('Host received liar call from client');
            
            // Get the current state and check if cards match
            final lastPlayedCards = _currentState['lastPlayedCards'] ?? [];
            final topLeftCard = _currentState['topLeftCard'];
            
            bool allCardsMatch = true;
            for (final card in lastPlayedCards) {
              final cardValue = card['value'];
              if (cardValue != topLeftCard && cardValue != 'Joker') {
                allCardsMatch = false;
                break;
              }
            }
            
            // Update game state based on the result
            final gameState = {
              'hasPressedLiar': true,
              'isPlayerCallingLiar': true,
              'logMessage': 'Client called Liar!'
            };
            
            _updateState(gameState);
            _broadcastState();
            
            // After a delay, update tokens
            Future.delayed(Duration(milliseconds: 4000), () {
              final newState = Map<String, dynamic>.from(_currentState);
              
              if (allCardsMatch) {
                // Client was wrong
                newState['player2Tokens'] = (newState['player2Tokens'] ?? 3) - 1;
                newState['logMessage'] = 'Client called Liar incorrectly and lost a token';
              } else {
                // Client was right
                newState['player1Tokens'] = (newState['player1Tokens'] ?? 3) - 1;
                newState['logMessage'] = 'Client called Liar correctly! Host lost a token';
              }
              
              newState['isPlayerCallingLiar'] = false;
              _updateState(newState);
              _broadcastState();
            });
          }
        }
      } catch (e) {
        print('Error in GameStateManager: $e');
      }
    },
    onError: (error) {
      print('GameStateManager stream error: $error');
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
void updateState(Map<String, dynamic> newState) {
  _updateState(newState);
  _broadcastState();
}

}